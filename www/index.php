<?php 
// This website can be accessed by NOC staff to monitor or accelerate SNMP verification of Airspan BSRs.
// The data is pushed through SOAP to Ofbiz ERP to set up the systems correctly.
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/util/LogUtil.class.inc");
require_once(ROOT."/common/db.inc");
?>
<html>
  <head>
    <title>Airspan WiMAX - CPE Inventory Sync to Ofbiz ERP</title>
    <style>
    table, th, td {
      border: 1px solid black;
      border-collapse: collapse;
    }    
    
    .alert {
      color: red;
    }
    
    .done {
      color: green;
    }
    
    .pending {
      color: orange;
    }
    </style>
  </head>
  <body>
    <p>
      <img src="RCS_banner.png" width="600px">
    </p>
    <h1>Airspan WiMAX - CPE Inventory Sync to Ofbiz ERP</h1>
    <h3>BSR SNMP Update</h3>
    <?php 
    if (isset($_POST["manual_check"])) {
      $log = "Manual SNMP check for ".$_POST["manual_check"]." has been requested by ".$_SERVER["REMOTE_ADDR"];      
      LogUtil::info(MODULE, $log);
      
      exec("nohup ".ROOT."/scripts/bsr_fetch.php ".$_POST["manual_check"]." > /dev/null 2>&1 &");     
      sleep(5);
      echo "<span class='alert'>SNMP check for BSR ".$_POST["manual_check"]." has been manually started.</span><br />";
    }    
    ?>    
    <table>
      <tr><th>BSR</th><th>IP</th><th>SNMP Last Check</th><th>SNMP Last Result</th><th>CPEs Online</th><th>CPEs Updated</th><th>New CPEs</th><th>Next Check Time</th><th>Check Now</th></tr>
    <?php 
      $bsr = $DB->query("SELECT * FROM bsr_check");
      while ($row = $bsr->fetch_assoc()) {
        if ($row["snmp_last_result"] == "RUNNING") {
          $next_check = "Unknown";
        } else {
          if (date("H") < 8) {
            //00:00 - 07:59
            $next_check_time = mktime(8, 0, 0, date("n"), date("j"), date("Y"));
          } else if (date("H") > 19) {
            //20:00 - 23:59
            $next_check_time = mktime(8, 0, 0, date("n"), date("j") + 1, date("Y"));
          } else {
            //08:00 - 19:59
            $next_check_time = mktime(date("H") + 1, 0, 0, date("n"), date("j"), date("Y"));
          }
          
          if ($next_check_time - time() < MIN_CHECK_INTERVAL * 60) {
            // Next check in less than x minutes
            $button = "N/A";
          } else if (time() - strtotime($row["snmp_last_check"]) < MIN_CHECK_INTERVAL * 60) { 
            //Previous check was less than x minutes ago
          } else {
            $button = '<form method="POST"><input type="hidden" name="manual_check" value="'.$row["ip"].'" /><input type="submit" value="Check Now"></form>';
          }
                    
          $next_check = date("Y-m-d H:i", $next_check_time);
        }
        
        echo "<tr><th>".$row["name"]."</td><td>".$row["ip"]."</td><td>".$row["snmp_last_check"]."</td><td>".$row["snmp_last_result"]."</td><td>".$row["cpe_online"]."</td><td>".$row["cpe_updated"]."</td><td>".$row["cpe_new"]."</td><td>$next_check</td><td>$button</td></tr>";
      }
      $bsr->free();    
    ?>
    </table>
  
    <h3>CPE List</h3>
    <form method="POST">
      <table>
        <tr>
          <th>MAC Address</th>
          <td><?php 
            $value = (isset($_POST['mac'])?$_POST['mac']:"00:A0:0A:");          
            echo '<input name="mac" type="text" value="'.$value.'" />';
          ?></td>
        </tr>
        <tr>
          <th>Base Station</th>
            <td><select name="bsr">
              <option value="any" <?php (isset($_POST['bsr']) && $_POST['bsr'] == 'any'?"selected":""); ?>>-- Any BSR --</option>
              <?php 
                $bsr = $DB->query("SELECT * FROM bsr_check");
                while ($row = $bsr->fetch_assoc()) {
                  $selected = (isset($_POST['bsr']) && $_POST['bsr'] == $row["ip"]?"selected":"");
                  echo "<option value=".$row["ip"]." $selected>".$row["name"]."</option>";
                }
                $bsr->free();
              ?>
            </select></td>
        </tr>
        <tr>
          <th>&nbsp;</th>
          <td><input type="submit" value="Find" /></td>
        </tr>
        <input type="hidden" name="cpe_lookup" value="1" />
      </table>
    </form>
    
    <?php 
    if (isset($_POST["cpe_lookup"])) {
      $config = array();
      
      $mac = $_POST['mac'];//TODO ESCAPE 
      $bsr = $_POST['bsr'];//TODO ESCAPE 
                   
      $condition = "WHERE mac LIKE '$mac%'";
      if ($bsr != 'any') {
        $condition .= " AND bsr_ip = '$bsr'";
      }
      
      $ms_config = $DB->query("SELECT * FROM ms_config $condition ORDER by mac");
      while ($row = $ms_config->fetch_assoc()) {              
        $tagged = "";
        $untagged = "";
        $vlan_status = "";
        $update = 0;
        $delete = 0;
        
        $ms_vlan_config = $DB->query("SELECT * FROM ms_vlan_config WHERE mac = '".$row["mac"]."' ORDER by vlan");
        while ($row2 = $ms_vlan_config->fetch_assoc()) {
          if ($row2["tagged"] == "0") {
            if ($untagged != '') $untagged .= ',';
            $untagged .= $row2["vlan"];
          } else {
            if ($tagged != '') $tagged .= ',';
            $tagged .= $row2["vlan"];
          }
          
          switch ($row2["updated"]) {
            case 1:  $update++;
                     break;
            case 2:  $delete++;
                     break;
          }          
        }
        $ms_vlan_config->free();
        
        if ($update > 0 || $delete > 0) {
          $vlan_status = "<span class='pending'>";
          if ($update > 0) $vlan_status .= "Update Pending ($update)<br />";
          if ($delete > 0) $vlan_status .= "Delete Pending ($delete)";       
          $vlan_status .= "</span>";          
        } else {
          $vlan_status = "<span class='done'>Unchanged</span>";
        }
                
        $config[] = array(
          "mac"           => $row["mac"],
          "bsr_ip"        => $row["bsr_ip"],
          "last_checked"  => $row["last_checked"],
          "vlan_type"     => $row["vlan_type"],
          "default_vlan"  => $row["default_vlan"],
          "updated"       => $row["updated"],
          "vlan_tagged"   => $tagged,
          "vlan_untagged" => $untagged,
          "vlan_status"   => $vlan_status,            
        );
      }
      $ms_config->free();      
    ?>
    <table>
        <tr>
          <th>MAC</th><th>Last Seen On</th><th>Last Check</th>
          <th>VLAN Type</th><th>Default VLAN</th><th>Update Status</th>
          <th>Tagged VLANs</th><th>Untagged VLANs</th><th>VLAN Update Status</th>
        </tr>
        <?php 
        foreach ($config as $row) {
          switch ($row["vlan_type"]) {
            case 1:  $type = "Admit All";
                     break;
            case 2:  $type = "Admit Tagged Only";
                     break;
            case 3:  $type = "Admit Untagged Only";
                     break;
            default: $type = "Unknown";
          }
          
          switch ($row["updated"]) {
            case 0:  $status = "<span class='done'>Unchanged</span>";
                     break;
            case 1:  $status = "<span class='pending'>Update Pending</span>";
                     break;
            case 2:  $status = "<span class='pending'>Delete Pending</span>";
                     break;
            default: $status = "Unknown";
          }
          
          echo "<tr><th>".$row["mac"]."</th><td>".$row["bsr_ip"]."</td><td>".$row["last_checked"]."</td>";
          echo "<td>$type</td><td>".$row["default_vlan"]."</td><td>$status</td>";
          echo "<td>".$row["vlan_tagged"]."</td><td>".$row["vlan_untagged"]."</td><td>".$row["vlan_status"]."</td></tr>";
        }
        ?>
    </table>
    
    <?php define("TOP_RF", 10); ?>
    <h4>RF Statistics (Last <?php echo TOP_RF; ?>)</h4>
    <?php 
      $rf_stats = array();
      
      $stats = $DB->query("SELECT * FROM rf_stats $condition ORDER by mac, check_time DESC");
      while ($row = $stats->fetch_assoc()) {       
        $rf_stats[$row["mac"]][$row["check_time"]] = array(
          "rssi_down"       => $row["rssi_down"],
          "rssi_up"         => $row["rssi_up"],
          "cinr_down"       => $row["cinr_down"],
          "cinr_up"         => $row["cinr_up"],
          "modulation_down" => $row["modulation_down"],
          "modulation_up"   => $row["modulation_up"],
          "mimo"            => $row["mimo"],
          "tx_power"        => $row["tx_power"],
          "status"          => $row["uploaded"],            
        );
      }
      $stats->free();  
    ?>
    <table>  
    <tr><th>Time</th><th>RSSI Down</th><th>RSSI Up</th><th>CINR Down</th><th>CINR Up</th><th>Modulation Down</th><th>Modulation Up</th><th>MIMO</th><th>TX Power</th><th>Status</th></tr>
    <?php
      foreach ($rf_stats as $mac => $cpe) {
        $row_count = 0;
        echo "<tr><th colspan='10'>$mac</th></tr>";
        foreach ($cpe as $time => $data) {
          if ($row_count < TOP_RF) {
            switch ($data["status"]) {
              case 0:  $status = "<span class='pending'>Upload Pending</span>";
                       break;              
              case 1:  $status = "<span class='done'>Uploaded</span>";
                       break;
              default: $status = "Unknown";            
            }
            
            echo "<tr><th>$time</th><td>".$data["rssi_down"]."</td><td>".$data["rssi_up"]."</td><td>".$data["cinr_down"]."</td><td>".$data["cinr_up"]."</td>";
            echo "<td>".$data["modulation_down"]."</td><td>".$data["modulation_up"]."</td><td>".$data["mimo"]."</td><td>".$data["tx_power"]."</td><td>$status</td</tr>";
          }
          $row_count++;
        }
      }
    ?>
    </table>
    
    <?php 
    }
    ?>
  </body>
</html>
<?php
$DB->close();
?>
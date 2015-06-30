<?php 
class AirspanDB {
  private $DB;
  private $BSR_IP;
  private $BS_vlans;
  private $MS_config;
  private $MS_rf_stats;  
  private $stats;
  
  public function __construct($DB, $BSR_IP, $BS_vlans, $MS_config, $MS_rf_stats) {
    $this->DB = $DB;
    $this->BSR_IP = $BSR_IP;
    
    $this->BS_vlans = $BS_vlans;
    $this->MS_config = $MS_config;
    $this->MS_rf_stats = $MS_rf_stats; 
    
    $this->stats = array(
      "cpe_online"  => 0,
      "cpe_updated" => 0,
      "cpe_new"     => 0,
      "cpe_removed" => 0,
    );   
  }
  
  public function verifyConfig() {
    $now = date("Y-m-d H:i:s");
    
    $this->stats["cpe_online"] = count($this->MS_config);
    
    // CPE Config
    $MS_VLAN_LIST = array();
    foreach ($this->MS_config as $MAC => $config) {
      $condition = "WHERE mac = '$MAC'";
      
      $ms_count = 0;
      $ms_config = $this->DB->query("SELECT * FROM ms_config $condition");
      while ($row = $ms_config->fetch_assoc()) {
        $config_db = $row;
        $ms_count++;
      }
      $ms_config->free();
      
      $cpe_updated = false;
      
      if ($ms_count == 0) {
        //New CPE !
        LogUtil::info(MODULE, "New Airspan MS found: $MAC");        
        $this->stats["cpe_new"] = $this->stats["cpe_new"] + 1;
        
        $this->DB->query("INSERT INTO ms_config VALUES ('$MAC', '".$config["vlan_type"]."', '".$config["default_vlan"]."', '".$this->BSR_IP."', '$now', '1')");
      } else if ($ms_count == 1) {
        //CPE already exists in DB
        if (
            $config["vlan_type"] != $config_db["vlan_type"] || 
            $config["default_vlan"] != $config_db["default_vlan"] ||
            $this->BSR_IP != $config_db["bsr_ip"] ) {
          LogUtil::info(MODULE, "Airspan MS $MAC has been updated since last check.");
          $cpe_updated = true;
          
          $this->DB->query("UPDATE ms_config SET vlan_type = '".$config["vlan_type"]."' $condition");
          $this->DB->query("UPDATE ms_config SET default_vlan = '".$config["default_vlan"]."' $condition");
          $this->DB->query("UPDATE ms_config SET bsr_ip = '".$this->BSR_IP."' $condition");
          $this->DB->query("UPDATE ms_config SET updated = '1' $condition");
        }       
        
        $this->DB->query("UPDATE ms_config SET last_checked = '$now' $condition");
      } else {
        //MAC is PK, so absolutely impossible !
        LogUtil::critical(MODULE, "Airspan MS with MAC $MAC was found more than once in the Database !");
        exit(3);
      }
      
      //VLAN Config                  
      foreach ($config["allowed"] as $VLAN => $tagged) {
        $condition2 = $condition." AND vlan = '$VLAN'";
        
        $vlan_count = 0;
        $ms_vlan_config = $this->DB->query("SELECT * FROM ms_vlan_config $condition2");
        while ($row = $ms_vlan_config->fetch_assoc()) {
          $vlan_config_db = $row;
          $vlan_count++;
        }
        $ms_vlan_config->free();
        
        if ($vlan_count == 0) {
          //New VLAN for CPE !     
          LogUtil::info(MODULE, "Airspan MS $MAC has new VLAN $VLAN attached.");
          $cpe_updated = true;             
          
          $this->DB->query("INSERT INTO ms_vlan_config VALUES ('$MAC', '$VLAN', '$tagged', '$now', '1')");
        } else if ($vlan_count == 1) {
          //VLAN for CPE already exists in DB

          if ($vlan_config_db["tagged"] != $tagged) {
            LogUtil::info(MODULE, "Airspan MS $MAC has VLAN $VLAN with changed tag type.");       

            //TODO
            LogUtil::warning(MODULE, "DEBUG --".$vlan_config_db["tagged"]."-- VS --".$tagged."--", true);
            
            $cpe_updated = true;             
            
            $this->DB->query("UPDATE ms_vlan_config SET tagged = '$tagged' $condition");
          }
        
          $this->DB->query("UPDATE ms_vlan_config SET last_checked = '$now' $condition");
        } else {
          //MAC+VLAN is PK, so absolutely impossible !
          LogUtil::critical(MODULE, "Airspan MS with MAC $MAC and VLAN $VLAN was found more than once in the Database !");
          exit(3);
        }
        
        //BSR Check
        if (!in_array($VLAN, $MS_VLAN_LIST)) {
          $MS_VLAN_LIST[] = $VLAN;
        }        
      }
      
      //VLAN Removal (Here I know the CPE was online/checked !!)
      $ms_vlan_config2 = $this->DB->query("SELECT * FROM ms_vlan_config $condition");
      while ($row2 = $ms_vlan_config2->fetch_assoc()) {
        if (time() - strtotime($row2["last_checked"]) > 60*60) {
          //This and previous check did not see VLAN as allowed, so needs to be removed !
          LogUtil::info(MODULE, "Airspan MS $MAC no longer has VLAN ".$row2["vlan"]." as allowed. Will remove it!");          
          $cpe_updated = true;

          $this->DB->query("UPDATE ms_vlan_config SET updated = '2' $condition AND vlan = '".$row2["vlan"]."'");
        }
      }
      $ms_vlan_config2->free();
      
      //Statistics update
      if ($cpe_updated) {
        $this->stats["cpe_updated"] = $this->stats["cpe_updated"] + 1;
      }
    }
    
    
    // MS Removal
    $ms_config2 = $this->DB->query("SELECT * FROM ms_config WHERE bsr_ip = '".$this->BSR_IP."'");
    while ($row2 = $ms_config2->fetch_assoc()) {
      if (time() - strtotime($row2["last_checked"]) > 60*60*24*OFFLINE_REMOVAL_DAYS) {
        // The CPE has been offline for x days. It can be cleaned up from the system.
        LogUtil::info(MODULE, "Airspan MS $MAC has been offline for ".OFFLINE_REMOVAL_DAYS." days. Will remove it!");        
        $this->stats["cpe_removed"] = $this->stats["cpe_removed"] + 1;
                
        $this->DB->query("UPDATE ms_config SET updated = '2' WHERE mac = '".$row2["mac"]."'");
      }
    }
    $ms_config2->free();
    
    
    // BSR Config
    $errorCount = 0;
    foreach ($this->BS_vlans as $BS_VLAN => $BS_config) {
      if ($BS_config["tagged"] != 0) {
        LogUtil::warning(MODULE, "Airspan BSR ".$this->BSR_IP." has VLAN $BS_VLAN configured with Tagged != 0 !");
        $errorCount++;
      }
      
      if ($BS_config["service_class"] != 3) {
        LogUtil::warning(MODULE, "Airspan BSR ".$this->BSR_IP." has VLAN $BS_VLAN configured with Service Class != 3 !");
        $errorCount++;
      }
      
      if (!in_array($BS_VLAN, $MS_VLAN_LIST)) {
        LogUtil::warning(MODULE, "Airspan BSR ".$this->BSR_IP." has VLAN $BS_VLAN configured, but it is not used by any connected CPEs !");
        $errorCount++;
        //TODO 
          // Should actually put this on webinterface
          // Tricky as at night you'll get many warnings...
          // Would need to compare to config DB ...
          // Logstash can do for now!
      }
    }
    
    foreach ($MS_VLAN_LIST as $MS_VLAN) {
      if (!array_key_exists($MS_VLAN, $this->BS_vlans)) {
        LogUtil::critical(MODULE, "An Airspan CPE with VLAN $MS_VLAN is connected to BSR ".$this->BSR_IP.", but the VLAN is not set up on this BSR !");
        $errorCount++;
      }
    }
    
    return $errorCount;
  }
  
  public function updateRFstats() {
    $now = date("Y-m-d H:i:s");
    
    foreach ($this->MS_rf_stats as $MAC => $statistics) {
      $this->DB->query(
          "INSERT INTO rf_stats VALUES ('$MAC', '".$this->BSR_IP."', '$now', '"
          .$statistics["rssi_down"]."', '".$statistics["rssi_up"]."', '"
          .$statistics["cinr_down"]."', '".$statistics["cinr_up"]."', '"
          .$statistics["modulation_down"]."', '".$statistics["modulation_up"]."', '"
          .$statistics["mimo"]."', '".$statistics["tx_power"]."', '0')");
    }
  }
  
  public function updateCheck() {
    $prefix = "UPDATE bsr_check SET";
    $suffix = "WHERE ip = '$this->BSR_IP'";
    
    $this->DB->query($prefix." cpe_online = '".$this->stats["cpe_online"]."' ".$suffix);
    $this->DB->query($prefix." cpe_updated = '".$this->stats["cpe_updated"]."' ".$suffix);
    $this->DB->query($prefix." cpe_new = '".$this->stats["cpe_new"]."' ".$suffix);
    $this->DB->query($prefix." cpe_removed = '".$this->stats["cpe_removed"]."' ".$suffix);    
    
    return $this->stats;
  }
}
?>
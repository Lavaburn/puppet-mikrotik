<?php
//Includes
require_once(ROOT."/lib/nusoap/nusoap.php");

//Static Settings
define("LOCAL_PATH", "/tmp");
define("REMOTE_PATH", "/tmp");
define("TIMEOUT", 2);

class Ofbiz {
  private $FIELDS = array(
      "rssi_down"       => "rssiD",
      "rssi_up"         => "rssiU",
      "cinr_down"       => "cinrD",
      "cinr_up"         => "cinrU",
      "modulation_down" => "modD",
      "modulation_up"   => "modU",
      "tx_power"        => "txPwr");
  
  private $DB;
  private $ofbiz;
		
  function __construct($DB, $hostname, $port) {
    $this->DB = $DB;
    $this->ofbiz = new soapclientnusoap("http://$hostname:$port/webtools/control/SOAPService/", false, false, false, false, false, 0, TIMEOUT*60);//Wait 2 minutes for response (much content in result)
  }
  
  public function pushAirspanConfig($IP) {
    $stats = array(
      "ms.update"       => array("success" => 0, "failure" => 0),
      "ms.delete"       => array("success" => 0, "failure" => 0),
      "ms_vlan.update"  => array("success" => 0, "failure" => 0),
      "ms_vlan.delete"  => array("success" => 0, "failure" => 0),
    );
    
    // MS config update
    $result = $this->DB->query("SELECT * FROM ms_config WHERE updated = '1' AND bsr_ip = '$IP'");
    while ($row = $result->fetch_array()) {
      //TODO COMMON FUNCTION (Webinterface ...)
      switch ($row["vlan_type"]) {
        case 1:   $vlan_type = "Admit All";
                  break;
        case 2:   $vlan_type = "Admit Tagged Only";
                  break;
        case 3:   $vlan_type = "Admit Untagged Only";
                  break;
        default:  $vlan_type = "Unknown";
      }
      
      $res = $this->updateWimaxAirspan($row["mac"], $vlan_type, $row["default_vlan"], $row["bsr_ip"]);
      if ($res) {
        LogUtil::info(MODULE, "Airspan MS ".$row["mac"]." has been uploaded to Ofbiz.");
        $stats["ms.update"]["success"] = $stats["ms.update"]["success"] + 1;
        
        $this->DB->query("UPDATE ms_config SET updated = '0' WHERE mac = '".$row["mac"]."'");
      } else {
        $stats["ms.update"]["failure"] = $stats["ms.update"]["failure"] + 1;
      }
    }
    
    
    // MS removal
    $result = $this->DB->query("SELECT * FROM ms_config WHERE updated = '2' AND bsr_ip = '$IP'");
    while ($row = $result->fetch_array()) {
      $res = $this->markForDeletionWimaxAirspan($row["mac"]);
      if ($res) {
        LogUtil::info(MODULE, "Airspan MS ".$row["mac"]." has been marked for deletion on Ofbiz.");
        $stats["ms.delete"]["success"] = $stats["ms.delete"]["success"] + 1;
      
        $this->archiveCPE($row["mac"]);
      } else {
        $stats["ms.delete"]["failure"] = $stats["ms.delete"]["failure"] + 1;
      }
    }
    
    
    // MS VLAN update
    $result = $this->DB->query("SELECT * FROM ms_vlan_config mvc JOIN ms_config mc ON mvc.mac = mc.mac WHERE mvc.updated = '1' AND bsr_ip = '$IP'");
    while ($row = $result->fetch_array()) {
      if ($row["vlan"] > 100) {
        //TODO COMMON FUNCTION (Webinterface ...)
        $tagged = ($row["tagged"] == 0 ? "untagged" : "tagged");
                
        $res = $this->updateWimaxAirspanVlan($row["mac"], $row["vlan"], $tagged);
        if ($res) {
          LogUtil::info(MODULE, "VLAN ".$row["vlan"]." for Airspan MS ".$row["mac"]." has been uploaded to Ofbiz.");
          $stats["ms_vlan.update"]["success"] = $stats["ms_vlan.update"]["success"] + 1;
          
          $this->DB->query("UPDATE ms_vlan_config SET updated = '0' WHERE mac = '".$row["mac"]."' AND vlan = '".$row["vlan"]."'");
        } else {
          $stats["ms_vlan.update"]["failure"] = $stats["ms_vlan.update"]["failure"] + 1;
        }
      } else {
        LogUtil::info(MODULE, "VLAN ".$row["vlan"]." for Airspan MS ".$row["mac"]." is a system VLAN and does not get uploaded to Ofbiz. Setting it as up-to-date.");
        
        $this->DB->query("UPDATE ms_vlan_config SET updated = '0' WHERE mac = '".$row["mac"]."' AND vlan = '".$row["vlan"]."'");
      }
    }
    
    
    // MS VLAN removal
    $result = $this->DB->query("SELECT * FROM ms_vlan_config mvc JOIN ms_config mc ON mvc.mac = mc.mac WHERE mvc.updated = '2' AND bsr_ip = '$IP'");
    while ($row = $result->fetch_array()) {
      $res = $this->verifyWimaxAirspanVlan($row["mac"]);
      if ($res) {
        LogUtil::info(MODULE, "VLAN ".$row["vlan"]." for Airspan MS ".$row["mac"]." has been marked for deletion on Ofbiz.");
        $stats["ms_vlan.delete"]["success"] = $stats["ms_vlan.delete"]["success"] + 1;
      
        $this->DB->query("DELETE FROM ms_vlan_config WHERE mac = '".$row["mac"]."' AND vlan = '".$row["vlan"]."'");
      } else {
        $stats["ms_vlan.delete"]["failure"] = $stats["ms_vlan.delete"]["failure"] + 1;
      }
    }
    
    return $stats;
  }
  
  public function pushRFstatistics() {
    $stats = array(
      "days"    => 0,
      "cpes"    => 0,
      "records" => 0,
      "upload"  => array("success" => 0, "failure" => 0),
    );
    
    $cpe_unique = array();
        
    
    //Get New Data
    $data = array();
    $real_date = array();
    $result = $this->DB->query("SELECT * FROM rf_stats WHERE uploaded = '0'");
    while ($row = $result->fetch_array()) {
      //Sort data per day and CPE
      $date = date("Ymd", strtotime($row["check_time"]));
      $cpe = $row["mac"];
                
      $data[$date][$cpe][] = $row;
      $real_date[$date] = date("Y-m-d", strtotime($row["check_time"]));
      
      if (!in_array($cpe, $cpe_unique)) $cpe_unique[] = $cpe;
      $stats["records"] = $stats["records"] + 1;
    }    
    $result->free();    
    
    $stats["days"] = count($data);
    $stats["cpes"] = count($cpe_unique);   

    //Create, Upload and Push File
    foreach ($data as $day => $records) {
      //File
      $fileName = "airspan_rf_$day.csv";
      $file = LOCAL_PATH."/$fileName";      
      $fp = fopen($file, "w");
      
      //Header
      $header = "mac;bs";
      foreach ($this->FIELDS as $field => $alias) {
        $header.= ";${alias}Min;${alias}Max;${alias}Avg";
      }
      $header .= "\n";      
      fwrite($fp, $header);
      
      //Records
      foreach ($records as $mac => $rows) {
        $bsr = "";
        foreach ($rows as $row) {
          $bsr = $row["bsr_ip"];
        }
        
        $summary = $this->summarizeStats($rows);
        
        $line = "$mac;$bsr";
        foreach ($this->FIELDS as $field => $alias) {
          $line .= ";".$summary["min"][$field].";".$summary["max"][$field].";".$summary["avg"][$field];
        }
        $line .= "\n";
        fwrite($fp, $line);
      }
      fclose($fp);
      
      //Upload
      shell_exec("scp $file ".OFBIZ_SERVER.":".REMOTE_PATH);
      
      //Push into OfBIZ
      $res = $this->uploadAirspanRFstats(REMOTE_PATH."/$fileName", $real_date[$day]);
      if ($res) {
        LogUtil::info(MODULE, count($records)." RF Statistics for ".$real_date[$day]." were successfully uploaded to Ofbiz (".OFBIZ_SERVER.").");
        $stats["upload"]["success"] = $stats["upload"]["success"] + 1;
        
        $this->DB->query("UPDATE rf_stats SET uploaded = '1' WHERE check_time > '".$real_date[$day]." 00:00:00' AND check_time < '".$real_date[$day]." 23:59:59'");
      } else {
        $stats["upload"]["failure"] = $stats["upload"]["failure"] + 1;
      }
    }
    
    return $stats;
  }
  
  private function updateWimaxAirspan($mac, $vlan_type, $default_vlan, $last_seen_on) {
    $params = array();
	$params["mac"] = $mac;
	$params["vlanType"] = $vlan_type;
	$params["defaultVlan"] = $default_vlan;
	$params["lastSeenOn"] = $last_seen_on;
				
	$result = $this->ofbiz->call('updateWimaxAirspan', $params);
	if (!$result || !array_key_exists("result", $result)) {
		if (is_array($result)) {
			if (array_key_exists("errorMessage", $result)) {
				$error = $result["errorMessage"];
			} else {
				$error = var_dump($result);
			}
		} else {
			$error = $result;
		}
			
		LogUtil::critical(MODULE, "Error while calling updateWimaxAirspan for $mac - ".$error);
		return false;				
	}
    return true;
  }
	
  private function markForDeletionWimaxAirspan($mac) {
    $params = array();
    $params["mac"] = $mac;
  
    $result = $this->ofbiz->call('markForDeletionWimaxAirspan', $params);
    if (!$result || !array_key_exists("result", $result)) {
      if (is_array($result)) {
        if (array_key_exists("errorMessage", $result)) {
          $error = $result["errorMessage"];
        } else {
          $error = var_dump($result);
        }
      } else {
        $error = $result;
      }
  
      LogUtil::critical(MODULE, "Error while calling markForDeletionWimaxAirspan for $mac - ".$error);
      return false;
    }
    return true;
  }
  
  private function updateWimaxAirspanVlan($mac, $vlan, $tagged) {
    $params = array();
    $params["cpe"] = $mac;
    $params["vlan"] = $vlan;
    $params["tagged"] = $tagged;
  
    $result = $this->ofbiz->call('updateWimaxAirspanVlan', $params);
    if (!$result || !array_key_exists("result", $result)) {
      if (is_array($result)) {
        if (array_key_exists("errorMessage", $result)) {
          $error = $result["errorMessage"];
        } else {
          $error = var_dump($result);
        }
      } else {
        $error = $result;
      }
      	
      LogUtil::critical(MODULE, "Error while calling updateWimaxAirspanVlan for $mac and VLAN $vlan - ".$error);
      return false;
    }
    return true;
  }
  	
  private function verifyWimaxAirspanVlan($mac) {
  	$params = array();
  	$params["mac"] = $mac;
  
  	$result = $this->ofbiz->call('verifyWimaxAirspanVlan', $params);
  	if (!$result || !array_key_exists("result", $result)) {
  		if (is_array($result)) {
  			if (array_key_exists("errorMessage", $result)) {
  				$error = $result["errorMessage"];
  			} else {
  				$error = var_dump($result);
  			}
  		} else {
  			$error = $result;
  		}
  					
  		LogUtil::critical(MODULE, "Error while calling verifyWimaxAirspanVlan for $mac - ".$error);
  		return false;
  	}
  	return true;
  }
  
  private function archiveCPE($mac) {
    $condition = "WHERE mac = '$mac'";
    
    $this->DB->query("INSERT INTO deleted_ms_config SELECT * FROM ms_config $condition");
    $this->DB->query("INSERT INTO deleted_ms_vlan_config SELECT * FROM ms_vlan_config $condition");
    
    $this->DB->query("DELETE FROM ms_config $condition");
    $this->DB->query("DELETE FROM ms_vlan_config $condition");
  }
  
  private function summarizeStats($rows) {
    $fieldSort = array();
    $summary = array();
    
    foreach ($rows as $row) {
      foreach ($this->FIELDS as $field => $alias) {
        $value = $row[$field];
        
        if ($field == "modulation_down") {
          $value = $row[$field] + ($row["mimo"]==1?10:0);//1 - 8 of 11 - 18
        }
        
        $fieldSort[$field][] = $value;
      }
    }
    
    foreach ($this->FIELDS as $field => $alias) {
      $summary["min"][$field] = min($fieldSort[$field]);
      $summary["max"][$field] = max($fieldSort[$field]);
      $summary["avg"][$field] = array_sum($fieldSort[$field]) / count($fieldSort[$field]);
    }
    return $summary;
  }
  
  private function uploadAirspanRFstats($fileName, $checkDate) {  	
  	$params = array();
  	$params["fileName"] = $fileName;
  	$params["checkDate"] = $checkDate;
  	
  	$result = $this->ofbiz->call('uploadAirspanRFstats', $params);
  	if (!$result || !array_key_exists("result", $result)) {
  		if (is_array($result)) {
  			if (array_key_exists("errorMessage", $result)) {
  				$error = $result["errorMessage"];
  			} else {
  				$error = var_dump($result);
  			}
  		} else {
  			$error = $result;
  		}
  	
  		LogUtil::critical(MODULE, "Error while calling uploadAirspanRFstats: ".$error);
  		return false;
  	}
  	return true;
  }	
}
?>
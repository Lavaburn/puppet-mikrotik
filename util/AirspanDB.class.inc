<?php 
class AirspanDB {
  private $database;
  private $bsrIp;
  private $bsVlans;
  private $msConfig;
  private $msRfStats;  
  private $stats;
  
  public function __construct($database, $bsrIp, $bsVlans, $msConfig, $msRfStats) {
    $this->database = $database;
    $this->bsrIp = $bsrIp;
    
    $this->bsVlans = $bsVlans;
    $this->msConfig = $msConfig;
    $this->msRfStats = $msRfStats; 
    
    $this->stats = array(
      "cpe_online"  => 0,
      "cpe_updated" => 0,
      "cpe_new"     => 0,
      "cpe_removed" => 0,
    );   
  }
  
  public function verifyConfig() {    
    //$this->stats["cpe_online"] = count($this->msConfig);
  	$this->stats["cpe_online"] = count($this->msRfStats);
    
    $msVlanList = $this->syncCpeConfig();
    $this->msRemoval();
    return $this->getBsrErrors($msVlanList);
  }

  private function getCpes($mac) {
  	$condition = "WHERE mac = '$mac'";
  		
  	$cpes = array();
  	$ms_config = $this->database->query("SELECT * FROM ms_config $condition");
  	while ($row = $ms_config->fetch_assoc()) {
  		$cpes[] = $row;
  	}
  	$ms_config->free();
  	return $cpes;
  }
    
  /**
   * @SuppressWarnings(PHPMD.ExitExpression)
   */
  private function syncCpeConfig() {
  	$now = date("Y-m-d H:i:s");
  	
  	$msVlanList = array();
  	//foreach ($this->msConfig as $mac => $config) {  	
  	foreach (array_keys($this->msRfStats) as $mac) {	// Only CURRENTLY ACTIVE CPEs !
  		$config = $this->msConfig[$mac];
  		
  		$cpeUpdated = false;
  		$cpes = $this->getCpes($mac);
  		if (count($cpes) == 0) {
  			//New CPE !
  			LogUtil::info(MODULE, "New Airspan MS found: $mac");
  			$this->stats["cpe_new"] = $this->stats["cpe_new"] + 1;
  	
  			$this->database->query("INSERT INTO ms_config VALUES ('$mac', '".$config["vlan_type"]."', '".$config["default_vlan"]."', '".$this->bsrIp."', '$now', '1')");
  		} else if (count($cpes) == 1) {
  			$cpeUpdated = $this->updateCpe($mac, $config, $cpes[0]);
  		} else {
  			//MAC is PK, so absolutely impossible !
  			LogUtil::critical(MODULE, "Airspan MS with MAC $mac was found more than once in the Database !");
  			exit(3);
  		}
  	
  		//VLAN Config
  		$msVlanList = $this->syncVlanConfig($mac, $config);
  	
  		//VLAN Removal (Here I know the CPE was online/checked !!)
  		$cpeUpdated = $this->cleanVlanConfig($cpeUpdated, $mac);
  	
  		//Statistics update
  		if ($cpeUpdated) {
  			$this->stats["cpe_updated"] = $this->stats["cpe_updated"] + 1;
  		}
  	}
  	return $msVlanList;
  }
  
  private function cleanVlanConfig($cpeUpdated, $mac) {
  	$condition = "WHERE mac = '$mac'";  	
  	
  	$ms_vlan_config2 = $this->database->query("SELECT * FROM ms_vlan_config $condition");
  	while ($row2 = $ms_vlan_config2->fetch_assoc()) {
  		if (time() - strtotime($row2["last_checked"]) > 60*60) {
  			//This and previous check did not see VLAN as allowed, so needs to be removed !
  			LogUtil::info(MODULE, "Airspan MS $mac no longer has VLAN ".$row2["vlan"]." as allowed. Will remove it!");
  			$cpeUpdated = true;
  	
  			$this->database->query("UPDATE ms_vlan_config SET updated = '2' $condition AND vlan = '".$row2["vlan"]."'");
  		}
  	}
  	$ms_vlan_config2->free();
  	return $cpeUpdated;
  }

  private function updateCpe($mac, $config, $dbConfig) {
  	$cpe_updated = false;
  	$now = date("Y-m-d H:i:s");
  	$condition = "WHERE mac = '$mac'";
  	 
  	if (
  			$config["vlan_type"] != $dbConfig["vlan_type"] ||
  			$config["default_vlan"] != $dbConfig["default_vlan"] ||
  			$this->bsrIp != $dbConfig["bsr_ip"] ) {
  		LogUtil::info(MODULE, "Airspan MS $mac has been updated since last check.");
  					
  		//DEBUG
  		LogUtil::info(MODULE, "Airspan MS $mac - VLAN TYPE: SNMP=-".$config["vlan_type"]."- vs. DB=-".$dbConfig["vlan_type"]."-");
  		LogUtil::info(MODULE, "Airspan MS $mac - DEFAULT VLAN: SNMP=-".$config["default_vlan"]."- vs. DB=-".$dbConfig["default_vlan"]."-");
  		LogUtil::info(MODULE, "Airspan MS $mac - BSR IP: SNMP=-".$this->bsrIp."- vs. DB=-".$dbConfig["bsr_ip"]."-");
  		//END DEBUG
  
  		$this->database->query("UPDATE ms_config SET vlan_type = '".$config["vlan_type"]."' $condition");
  		$this->database->query("UPDATE ms_config SET default_vlan = '".$config["default_vlan"]."' $condition");
  		$this->database->query("UPDATE ms_config SET bsr_ip = '".$this->bsrIp."' $condition");
  		$this->database->query("UPDATE ms_config SET updated = '1' $condition");
  
  		$cpe_updated = true;
  	}
  
  	$this->database->query("UPDATE ms_config SET last_checked = '$now' $condition");
  		 
  	return $cpe_updated;
  }

  /**
   * @SuppressWarnings(PHPMD.ExitExpression)
   */
  private function syncVlanConfig($mac, $config) {
    $now = date("Y-m-d H:i:s");
  	$msVlanList = array();
  	$condition = "WHERE mac = '$mac'";
  	   	 
  	foreach ($config["allowed"] as $VLAN => $tagged) {
  		$condition2 = $condition." AND vlan = '$VLAN'";
  		 
  		$vlan_count = 0;
  		$ms_vlan_config = $this->database->query("SELECT * FROM ms_vlan_config $condition2");
  		while ($row = $ms_vlan_config->fetch_assoc()) {
  			$vlan_config_db = $row;
  			$vlan_count++;
  		}
  		$ms_vlan_config->free();
  		 
  		if ($vlan_count == 0) {
  			//New VLAN for CPE !
  			LogUtil::info(MODULE, "Airspan MS $mac has new VLAN $VLAN attached.");
  			$cpe_updated = true;
  			 
  			$this->database->query("INSERT INTO ms_vlan_config VALUES ('$mac', '$VLAN', '$tagged', '$now', '1')");
  		} else if ($vlan_count == 1) {
  			//VLAN for CPE already exists in DB
  			 
  			if ($vlan_config_db["tagged"] != $tagged) {
  				LogUtil::info(MODULE, "Airspan MS $mac has VLAN $VLAN with changed tag type.");
  				$cpe_updated = true;
  				 
  				$this->database->query("UPDATE ms_vlan_config SET tagged = '$tagged' $condition2");
  			}
  			 
  			$this->database->query("UPDATE ms_vlan_config SET last_checked = '$now' $condition2");
  		} else {
  			//MAC+VLAN is PK, so absolutely impossible !
  			LogUtil::critical(MODULE, "Airspan MS with MAC $mac and VLAN $VLAN was found more than once in the Database !");
  			exit(3);
  		}
  		 
  		//BSR Check
  		if (!in_array($VLAN, $msVlanList)) {
  			$msVlanList[] = $VLAN;
  		}
  	}
  	return $msVlanList;
  }
  
  private function msRemoval() {
  	$ms_config2 = $this->database->query("SELECT * FROM ms_config WHERE bsr_ip = '".$this->bsrIp."'");
  	while ($row2 = $ms_config2->fetch_assoc()) {
  		if (time() - strtotime($row2["last_checked"]) > 60*60*24*OFFLINE_REMOVAL_DAYS) {
  			// The CPE has been offline for x days. It can be cleaned up from the system.
  			LogUtil::info(MODULE, "Airspan MS ".$row2["mac"]." has been offline for ".OFFLINE_REMOVAL_DAYS." days. Will remove it!");
  			$this->stats["cpe_removed"] = $this->stats["cpe_removed"] + 1;
  			 
  			$this->database->query("UPDATE ms_config SET updated = '2' WHERE mac = '".$row2["mac"]."'");
  		}
  	}
  	$ms_config2->free();
  }
  
  private function getBsrErrors($msVlanList) {
  	$errorCount = 0;
  	foreach ($this->bsVlans as $BS_VLAN => $BS_config) {
  		if ($BS_config["tagged"] != 0) {
  			LogUtil::warning(MODULE, "Airspan BSR ".$this->bsrIp." has VLAN $BS_VLAN configured with Tagged != 0 !");
  			$errorCount++;
  		}
  	
  		if ($BS_config["service_class"] != 3) {
  			LogUtil::warning(MODULE, "Airspan BSR ".$this->bsrIp." has VLAN $BS_VLAN configured with Service Class != 3 !");
  			$errorCount++;
  		}
  	
  		if (!in_array($BS_VLAN, $msVlanList)) {
  			LogUtil::warning(MODULE, "Airspan BSR ".$this->bsrIp." has VLAN $BS_VLAN configured, but it is not used by any connected CPEs !");
  			$errorCount++;
  			//TODO
  			// Should actually put this on webinterface
  			// Tricky as at night you'll get many warnings...
  			// Would need to compare to config DB ...
  			// Logstash can do for now!
  		}
  	}
  	
  	foreach ($msVlanList as $MS_VLAN) {
  		if (!array_key_exists($MS_VLAN, $this->bsVlans)) {
  			LogUtil::critical(MODULE, "An Airspan CPE with VLAN $MS_VLAN is connected to BSR ".$this->bsrIp.", but the VLAN is not set up on this BSR !");
  			$errorCount++;
  		}
  	}
  	
  	return $errorCount;
  }
  
  public function updateRFstats() {
    $now = date("Y-m-d H:i:s");
    
    foreach ($this->msRfStats as $MAC => $statistics) {
      $this->database->query(
          "INSERT INTO rf_stats VALUES ('$MAC', '".$this->bsrIp."', '$now', '"
          .$statistics["rssi_down"]."', '".$statistics["rssi_up"]."', '"
          .$statistics["cinr_down"]."', '".$statistics["cinr_up"]."', '"
          .$statistics["modulation_down"]."', '".$statistics["modulation_up"]."', '"
          .$statistics["mimo"]."', '".$statistics["tx_power"]."', '0')");
    }
  }
  
  public function updateCheck() {
    $prefix = "UPDATE bsr_check SET";
    $suffix = "WHERE ip = '$this->bsrIp'";
    
    $this->database->query($prefix." cpe_online = '".$this->stats["cpe_online"]."' ".$suffix);
    $this->database->query($prefix." cpe_updated = '".$this->stats["cpe_updated"]."' ".$suffix);
    $this->database->query($prefix." cpe_new = '".$this->stats["cpe_new"]."' ".$suffix);
    $this->database->query($prefix." cpe_removed = '".$this->stats["cpe_removed"]."' ".$suffix);    
    
    return $this->stats;
  }
}
?>
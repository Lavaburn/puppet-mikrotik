#!/usr/bin/php
<?
$time = microtime(true);

//Constants
define("DEBUG", false);
define("LOCATION", "Juba");
define("COMMUNITY", "public");

//OID List
define("OID_SYSTEM",				"1.3.6.1.2.1.1");
define("OID_PRIVATE", 				"1.3.6.1.4.1");

define("OID_AIRSPAN", 		OID_PRIVATE.	".989.1.16");
define("OID_CPE_LIST", 		OID_AIRSPAN.	".2.9.2.1");
define("OID_VLAN_SRV", 		OID_AIRSPAN.	".5.4.1.2.1.16");//.90 => Service Profile (3 = multicast group)
define("OID_VLAN_BS", 		OID_AIRSPAN.	".5.4.2.4.1.2.4");//.90 => (0 = tagged)
define("OID_VLAN_CPE", 		OID_AIRSPAN.	".5.4.2");

define("OID_VLAN_CPE_PVID", 	OID_VLAN_CPE.	".1.1.4.1");
define("OID_VLAN_CPE_TYPE", 	OID_VLAN_CPE.	".1.1.6.1");
define("OID_VLAN_CPE_TAGGED", 	OID_VLAN_CPE.	".2.1.3.1");

//Persistence
$DB = new mysqli('tools.dmz.rcswimax.com', 'statistics', 'wimax2013juba', 'wimax_stats');

//Retrieve Airspan Radios
$status = array();
$result = $DB->query("SELECT * FROM basestations WHERE type = 'AIR4G'");
while ($row = $result->fetch_array()) {
	$basestations[$row["name"]] = $row["ip"];
}
$result->free();

foreach ($basestations as $name => $ip) {	
	$vlans = array();
	$ms_stats = array();
	$ms_config = array();
	
	//VLAN Configuration and Basestation config
	$vlan_srv = @snmprealwalk($ip, COMMUNITY, OID_VLAN_SRV);
	if ($vlan_srv) {
		foreach ($vlan_srv as $oid => $service_class) {
			$service_class = clean($service_class);
			$VLAN = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.5.4.1.2.1.16./", "", $oid);
			$vlans[$VLAN]["service_class"] = $service_class;
		}
	}

	$vlan_bs = @snmprealwalk($ip, COMMUNITY, OID_VLAN_BS);
	if ($vlan_bs) {
		foreach ($vlan_bs as $oid => $tagged) {
			$tagged = clean($tagged);
			$VLAN = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.5.4.2.4.1.2.4./", "", $oid);
			$vlans[$VLAN]["tagged"] = $tagged;
		}
	}

	//CPE Statistics
	$cpe_stats = @snmprealwalk($ip, COMMUNITY, OID_CPE_LIST);
	if ($cpe_stats) {
		foreach ($cpe_stats as $oid => $data) {
			$oid_part2 = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.2.9.2.1./", "", $oid);
			$oid_parts = explode("." , $oid_part2);
			
			$index = $oid_parts[0];
			
			$MAC_decimal = preg_replace("/$index.1./", "", $oid_part2, 1);
			$MAC = macDecToHex($MAC_decimal);

			$value = clean($data);

			switch ($index) {
				case 1:		$ms_stats[$MAC]["rssi_down"] = $value - 123;
						break;
				case 2:		$ms_stats[$MAC]["rssi_up"] = $value / 4;
						break;
				case 12:	$ms_stats[$MAC]["cinr_down"] = $value / 4;
						break;
				case 5:		$ms_stats[$MAC]["cinr_up"] = $value / 4;
						break;
				case 14:	$ms_stats[$MAC]["modulation_down"] = $value + 1;//0 = QPSK1/2, 7 = 64QAM5/6
						break;
				case 6:		$ms_stats[$MAC]["modulation_up"] = $value;// 8 = 64QAM5/6, 1 = QPSK1/2
						break;
				case 11:	$ms_stats[$MAC]["mimo"] = $value;//0 = MatrixA, 1 = MatrixB
						break;
				case 13:	$ms_stats[$MAC]["tx_power"] = $value;
						break;
				default: 	//Do Nothing
			 }
		}
	}

	//CPE VLAN Configuration
	$cpe_vlan_pvid = @snmprealwalk($ip, COMMUNITY, OID_VLAN_CPE_PVID);
	if ($cpe_vlan_pvid) {
		foreach ($cpe_vlan_pvid as $oid => $data) {
			$MAC_decimal = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.5.4.2.1.1.4.1./", "", $oid);

			$MAC = macDecToHex($MAC_decimal);
			$value = clean($data);//INTEGER: 1003	=> PVID (Untagged Traffic VLAN)

			$ms_config[$MAC]["default_vlan"] = $value;
		}
	}

	$cpe_vlan_type = @snmprealwalk($ip, COMMUNITY, OID_VLAN_CPE_TYPE);
	if ($cpe_vlan_type) {
		foreach ($cpe_vlan_type as $oid => $data) {
			$MAC_decimal = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.5.4.2.1.1.6.1./", "", $oid);

			$MAC = macDecToHex($MAC_decimal);
			$value = clean($data);//INTEGER: 1	=> admitAll(1), admitOnlyUntagged(3)

			$ms_config[$MAC]["vlan_type"] = $value;
		}
	}

	$cpe_vlan_tagged = @snmprealwalk($ip, COMMUNITY, OID_VLAN_CPE_TAGGED);
	if ($cpe_vlan_tagged) {
		foreach ($cpe_vlan_tagged as $oid => $data) {
			$oid_part2 = preg_replace("/SNMPv2-SMI::enterprises.989.1.16.5.4.2.2.1.3.1./", "", $oid);
			$oid_parts = explode("." , $oid_part2);

			$MAC_decimal = "";
			for ($i = 0; $i < 6; $i++) {
				if ($MAC_decimal != "") $MAC_decimal .= ".";
				$MAC_decimal .= $oid_parts[$i];
			}
			$MAC = macDecToHex($MAC_decimal);

			$VLAN = $oid_parts[$i];
			$value = clean($data);//(0 = tagged)
			if ($value == 0) {
				$value = 1;
			} else {
				$value = 0;
			}

			$ms_config[$MAC]["allowed"][$VLAN] = $value;
		}
	}

	//Parse 
	foreach ($ms_stats as $MAC => $data) {
		addRFStats($MAC, $ip, $data["rssi_down"], $data["rssi_up"], $data["cinr_down"], $data["cinr_up"], $data["modulation_down"], $data["modulation_up"], $data["mimo"], $data["tx_power"]);

		$verify = array();

		$data = $ms_config[$MAC];
		updateConfig($MAC, $data["vlan_type"], $data["default_vlan"]);

		$verify[] = $data["default_vlan"];
		if (is_array($data["allowed"])) {
		foreach ($data["allowed"] as $vlan => $tagged) {
			updateVLANConfig($MAC, $vlan, $tagged);
			$verify[] = $vlan;
		}
		}
		verifyVLANConfig($MAC, $verify, $vlans);		
	}
}

//FUNCTIONS
function clean($raw) {
	$raw = preg_replace("/INTEGER: /", "", $raw);
	$raw = preg_replace("/Counter32: /", "", $raw);
	$raw = preg_replace("/IpAddress: /", "", $raw);
	if (preg_match("/Hex-STRING: /", $raw)) {
		$raw = preg_replace("/Hex-STRING: /", "", $raw);
	}
	if (preg_match("/STRING: /", $raw)) {
		$raw = preg_replace("/STRING: /", "", $raw);
		$raw = preg_replace("/\"/", "", $raw);
	}
	return $raw;
}

function macDecToHex($dec) {
	$hex = "";
	$parts = explode("." , $dec);
	foreach ($parts as $part) {
		if ($hex != "") $hex .= ":";
		$hex .= ($part<16?"0":"").strtoupper(dechex($part));
	}
	return $hex;
}

function addRFStats($MAC, $ip, $rssi_down, $rssi_up, $cinr_down, $cinr_up, $modulation_down, $modulation_up, $mimo, $tx_power) {
	global $DB;

	$now = date("Y-m-d H:i:s");
	
	if (DEBUG) echo "Added RF: $MAC\n";
	
	//If BS changed => mark for update!	
	$resultB = $DB->query("SELECT bs FROM rf_stats WHERE check_time IN (SELECT MAX(check_time) FROM rf_stats WHERE mac = '$MAC') AND mac = '$MAC'");
	while ($rowB = $resultB->fetch_array()) {
		$previousBS = $rowB["bs"];
		
		if ($previousBS != $ip) {
			$DB->query("UPDATE cpe_config SET uploaded = '0' WHERE mac = '$MAC'");
		}
	}
	
	$DB->query("INSERT INTO rf_stats VALUES ('$MAC', '$ip', '$now', '$rssi_down', '$rssi_up', '$cinr_down', '$cinr_up', '$modulation_down', '$modulation_up', '$mimo', '$tx_power')");
}

function updateConfig($MAC, $vlan_type, $default_vlan) {
	global $DB;

	$today = date("Y-m-d");
	$WHERE = "WHERE mac = '$MAC'";

	$result = $DB->query("SELECT * FROM cpe_config $WHERE");
	if ($result->num_rows > 0) {	
		while ($row = $result->fetch_array()) {
			$updated = false;			

			if ($row["vlan_type"] != $vlan_type) {
				$DB->query("UPDATE cpe_config SET vlan_type = '$vlan_type' $WHERE");
				$updated = true;
			}
			if ($row["default_vlan"] != $default_vlan) {
				$DB->query("UPDATE cpe_config SET default_vlan = '$default_vlan' $WHERE");	
				$updated = true;		
			}
			if ($updated) {
				if (DEBUG) echo "Updated config: $MAC\n";
				$DB->query("UPDATE cpe_config SET updated = '$today' $WHERE");	
			}
		}		
	} else {
		if (DEBUG) echo "Added config: $MAC\n";
		$DB->query("INSERT INTO cpe_config VALUES ('$MAC', '$vlan_type', '$default_vlan', '$today', '0')");
	}
	$result->free();
}

function updateVLANConfig($MAC, $vlan, $tagged) {
	global $DB;

	$today = date("Y-m-d");
	$WHERE = "WHERE mac = '$MAC' and vlan = '$vlan'";

	$result = $DB->query("SELECT * FROM cpe_vlan_list $WHERE");
	if ($result->num_rows > 0) {	
		while ($row = $result->fetch_array()) {
			if ($row["tagged"] != $tagged) {
				$DB->query("UPDATE cpe_vlan_list SET tagged = '$tagged' $WHERE");	
				$DB->query("UPDATE cpe_vlan_list SET updated = '$today' $WHERE");	
				if (DEBUG) echo "Updated VLAN config: $MAC - $vlan\n";
			}
		}
	} else {
		if (DEBUG) echo "Added VLAN config: $MAC - $vlan\n";
		$DB->query("INSERT INTO cpe_vlan_list VALUES ('$MAC', '$vlan', '$tagged', '$today')");
	}
	$result->free();
}

function verifyVLANConfig($MAC, $vlan_list, $vlan_config) {
	global $DB;

	$result = $DB->query("SELECT * FROM cpe_vlan_list WHERE mac = '$MAC'");
	while ($row = $result->fetch_array()) {
		$vlan = $row["vlan"];
		if (!in_array($vlan, $vlan_list)) {
			if (DEBUG) echo "VLAN $vlan is no longer in use by $MAC.";
			$DB->query("DELETE FROM cpe_vlan_list WHERE mac = '$MAC' AND vlan = '$vlan'");
		}
	}

	$today = date("Y-m-d");

	//Service Flow should be 3!
	foreach ($vlan_list as $VLAN) {
		$SC = $vlan_config[$VLAN]["service_class"];
		if ($SC != 3) {
			$error = "VLAN $VLAN in use by $MAC is configured with Service Class $SC (<> 3).";
			if (DEBUG) echo $error;

			$add = true;
			$result = $DB->query("SELECT * FROM config_errors WHERE mac = '$MAC' AND added = '$today'");
			if ($result->num_rows > 0) {	
				while ($row = $result->fetch_array()) {
					if ($row["error"] == $error) {
						$add = false;
					}
				}
			} 

			if ($add) {
				$DB->query("INSERT INTO config_errors VALUES ('$MAC', '$today', '$error')");
			}
			$result->free();
		}
	}
}

$time = (microtime(true) - $time) / 1000;
if (DEBUG) echo "Runtime: $time s";
?>

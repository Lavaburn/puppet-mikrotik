#!/usr/bin/php
<?php
$time = microtime(true);
openlog("[AIRSPAN_SOAP]", LOG_ODELAY, LOG_USER);

//Parameters
$FULLUPDATE = false;

$ARGV = $_SERVER['argv'];
if (isset($ARGV[1])) {
	if ($ARGV[1] == "FULL_UPDATE") {
		$FULLUPDATE = true;
	} else {
		$SELECTED_MAC = $ARGV[1];
	}
}

//Constants
define("ERPSERVER", "216.250.115.253");
define("SCRIPTDIR", "/etc/scripts/erp/");

//Includes
require_once(SCRIPTDIR.'lib/nusoap/nusoap.php');

//Persistence
$DB = new mysqli('tools.dmz.rcswimax.com', 'statistics', 'wimax2013juba', 'wimax_stats');
$soap = new soapclientnusoap('http://'.ERPSERVER.':8080/webtools/control/SOAPService/');

//Get Data
$result = $DB->query("SELECT * FROM cpe_config");
while ($row = $result->fetch_array()) {
	$mac = $row["mac"];
	
	if (isset($SELECTED_MAC)) {
		if ($mac != $SELECTED_MAC) continue;
	} else {	
		if (!$FULLUPDATE) {			
			if ($row["uploaded"] == 1) {
				continue;
			}
		}
	}
	
	$params = array();
	$params["mac"] = $row["mac"];
	$params["vlanType"] = cleanValue("vlanType", $row["vlan_type"]);
	$params["defaultVlan"] = $row["default_vlan"];

	//Last connected to BaseStation x
	$result2 = $DB->query("SELECT bs FROM rf_stats WHERE mac = '$mac' ORDER BY check_time DESC LIMIT 1");
	while ($row2 = $result2->fetch_array()) {
		$params["lastSeenOn"] = $row2["bs"];
	}
	$result2->free();

	//Call Ofbiz
	$resulta = $soap->call('updateWimaxAirspan', $params);
	if (!$resulta->result) {
		syslog(LOG_INFO, "updateWimaxAirspan called for $mac: ERROR - ".$resulta->result);
	} else {
		syslog(LOG_INFO, "updateWimaxAirspan called without errors for $mac");
	}
	
	//Log as uploaded - update only from now
	if ($row["uploaded"] == 0) {
		$DB->query("UPDATE cpe_config SET uploaded = '1' WHERE mac = '$mac'");
	}

	$result1 = $DB->query("SELECT * FROM cpe_vlan_list WHERE mac = '$mac'");
	while ($row1 = $result1->fetch_array()) {
		$vlan = $row1["vlan"];

		//No network tags
		if ($vlan > 100) {
			$params = array();
			$params["cpe"] = $row1["mac"];
			$params["vlan"] = $row1["vlan"];
			$params["tagged"] = cleanValue("tagged", $row1["tagged"]);

			//Call Ofbiz
			$resultb = $soap->call('updateWimaxAirspanVlan', $params);
			if (!$resultb->result) {
				syslog(LOG_INFO, "updateWimaxAirspanVlan called for $mac: ERROR - ".$resultb->result);
			} else {
				syslog(LOG_INFO, "updateWimaxAirspanVlan called without errors for $mac");
			}
		}
	}
	$result1->free();
	
	//Check Date of last contact
	$lastUpdate = "2010-01-01";
	$result3 = $DB->query("SELECT MAX(check_time) as last_update FROM rf_stats WHERE mac = '$mac'");
	while ($row3 = $result3->fetch_array()) {
		$lastUpdate = $row3["last_update"];
	}
	$result3->free();
	
	$diff = strtotime("now") - strtotime($lastUpdate);
	if ($diff / 3600 / 24 / 30 > 6) {
		$param2 = array();
		$param2["mac"] = $mac;		
		$resc = $soap->call('markForDeletionWimaxAirspan', $param2);
		if (!$resc->result) {
			syslog(LOG_INFO, "markForDeletionWimaxAirspan called for $mac: ERROR - ".$resc->result);
		} else {
			syslog(LOG_INFO, "markForDeletionWimaxAirspan called without errors for $mac");
		}
		
		$DB->query("INSERT INTO archive_cpe_config SELECT * FROM cpe_config WHERE mac = '$mac'");
		$DB->query("INSERT INTO archive_cpe_vlan_list SELECT * FROM cpe_vlan_list WHERE mac = '$mac'");
		$DB->query("INSERT INTO archive_rf_stats SELECT * FROM rf_stats WHERE mac = '$mac'");	
		$DB->query("DELETE FROM cpe_config WHERE mac = '$mac'");
		$DB->query("DELETE FROM cpe_vlan_list WHERE mac = '$mac'");
		$DB->query("DELETE FROM rf_stats WHERE mac = '$mac'");
	}	
}
$result->free();

//Delete (remote) old data
if ($FULLUPDATE) {
	$resultc = $soap->call('verifyWimaxAirspanVlan', array());
	if (!$resultc->result) {
		syslog(LOG_INFO, "verifyWimaxAirspanVlan called: ERROR - ".$resultc->result);
	} else {
		syslog(LOG_INFO, "verifyWimaxAirspanVlan called without errors");
	}
}

//Functions
function cleanValue($field, $value) {
	switch ($field) {
		case "vlanType": 	switch ($value) {
						case 1: return "Admit All";
						case 2: return "Admit Tagged Only";
						case 3: return "Admit Untagged Only";
						default: return "UNKNOWN";
					}
		case "tagged": 		return ($value == 0 ? "untagged" : "tagged");
		default : 		return $value;
	}
}
?>

#!/usr/bin/php
<?php 
// Fetch SNMP Data for Airspan BSR
// This script is called hourly (9 AM - 6 PM) by crontab or manually from webinterface.
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/AirspanDB.class.inc");
require_once(ROOT."/util/GraphiteUtil.class.inc");
require_once(ROOT."/util/LogUtil.class.inc");
require_once(ROOT."/util/Ofbiz.class.inc");
require_once(ROOT."/util/SNMPUtil.class.inc");
require_once(ROOT."/util/Timer.class.inc");
require_once(ROOT."/util/Util.class.inc");

//Parameters
$IP = $argv[1];
LogUtil::info(MODULE, "SNMP check for Airspan BSR $IP has been requested.");


//Update Database - Script started
Timer::start();

$bsr_count = 0;
$bsr = $DB->query("SELECT * FROM bsr_check WHERE ip = '$IP'");
while ($row = $bsr->fetch_assoc()) {
  $bsr_name = $row["name"];
  $bsr_shortname = $row["shortname"];
  $bsr_count++;
}
$bsr->free();

if ($bsr_count == 0) {
  LogUtil::critical(MODULE, "Airspan BSR $IP was not found in the Database !");
  exit(2);
} else if ($bsr_count > 1) {
  LogUtil::critical(MODULE, "Airspan BSR $IP was found more than once in the Database !");
  exit(2);
}

$DB->query("UPDATE bsr_check SET snmp_last_check = NOW() WHERE ip = '$IP'");
$DB->query("UPDATE bsr_check SET snmp_last_result = 'RUNNING' WHERE ip = '$IP'");

$exit_status = "SUCCESS";

// SNMP Fetch
// A1 - BSR VLAN Configuration - Service Class
$VLANs = array();
$bs_vlan_service_class = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_BS_VLAN_SERVICE_CLASS);
foreach ($bs_vlan_service_class as $VLAN => $service_class) {
  $VLANs[$VLAN]["service_class"] = $service_class;
}

// A2 - BSR VLAN Configuration - Tagging
$bs_vlan_tagged = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_BS_VLAN_TAGGED);
foreach ($bs_vlan_tagged as $VLAN => $tagged) {
  $VLANs[$VLAN]["tagged"] = $tagged;
}

// A - SNMP Error, still shows up even if removed from profile (??)
foreach ($VLANs as $VLAN => $config) {
  if (!isset($config["tagged"])) {
    unset($VLANs[$VLAN]);
  }
}


// B1 - CPE List - VLAN Configuration - Untagged Traffic VLAN
$ms_config = array();
$cpe_config_pvid = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_CPE_CONFIG_PVID);
foreach ($cpe_config_pvid as $MAC_decimal => $pvid) {
  $MAC = Util::convertMAC($MAC_decimal);
  $ms_config[$MAC]["default_vlan"] = $pvid;
}

// B2 - CPE List - VLAN Configuration - Type
$cpe_config_type = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_CPE_CONFIG_TYPE);
foreach ($cpe_config_type as $MAC_decimal => $type) {
  $MAC = Util::convertMAC($MAC_decimal);
  $ms_config[$MAC]["vlan_type"] = $type;//admitAll(1), admitOnlyUntagged(3)
}

// B3 - CPE List - Tagged
$cpe_config_tagged = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_CPE_CONFIG_TAGGED);
foreach ($cpe_config_tagged as $oid_suffix => $type) {
  $oid_suffix_parts = explode("." , $oid_suffix);
  
  $MAC_decimal = "";
  for ($i = 0; $i < 6; $i++) {
    if ($MAC_decimal != "") $MAC_decimal .= ".";
    $MAC_decimal .= $oid_suffix_parts[$i];
  }
  $MAC = Util::convertMAC($MAC_decimal);
  
  $VLAN = $oid_suffix_parts[$i];
  
  $ms_config[$MAC]["allowed"][$VLAN] = ($type==0?1:0);//Swap 0 and 1
}

// C - CPE List - RF Statistics
$ms_stats = array();
$cpe_stats = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_CPE_RF_STATS);
foreach ($cpe_stats as $oid_suffix => $value) {
  $oid_suffix_parts = explode("." , $oid_suffix);
  $index = $oid_suffix_parts[0];

  $MAC_decimal = preg_replace("/^$index\.1\./", "", $oid_suffix);
  $MAC = Util::convertMAC($MAC_decimal);

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

// SNMP Error, incomplete result.
foreach ($ms_stats as $MAC => $config) {
  if (!isset($config["rssi_down"])
      || !isset($config["rssi_up"])
      || !isset($config["cinr_down"])
      || !isset($config["cinr_up"])
      || !isset($config["modulation_down"])
      || !isset($config["modulation_up"])
      || !isset($config["mimo"])
      || !isset($config["tx_power"])) {
    unset($ms_stats[$MAC]);
  }
}


if (
  count($bs_vlan_service_class) == 0 ||
  count($bs_vlan_tagged) == 0 ||
  count($cpe_config_pvid) == 0 ||
  count($cpe_config_type) == 0 ||
  count($cpe_config_tagged) == 0 ||
  count($cpe_stats) == 0
) {
  $exit_status = "SNMP_ERROR";
}


// Put all the data together now !
$airspanDB = new AirspanDB($DB, $IP, $VLANs, $ms_config, $ms_stats);

//Verify and Update (DB) MS config - Verify BSR config
$errorCount = $airspanDB->verifyConfig();
if ($errorCount > 0) {
  $exit_status = "COMPLETED with $errorCount warnings.";
}

//Update RF Stats for MS
$airspanDB->updateRFstats();

//Update statistics to DB
$stats = $airspanDB->updateCheck();

// SOAP Push 
$ofbiz = new Ofbiz($DB, OFBIZ_SERVER, OFBIZ_PORT);
$ofbiz_stats = $ofbiz->pushAirspanConfig($IP);

//Finish Run
$runtime = round(Timer::stop());

//Push Stats to Graphite
$graph = new GraphiteUtil(GRAPHITE_HOST, GRAPHITE_PORT, GRAPHITE_PREFIX.".config");
$graph->send($bsr_shortname.".ms.online", $stats["cpe_online"]);
$graph->send($bsr_shortname.".ms.updated", $stats["cpe_updated"]);
$graph->send($bsr_shortname.".ms.new", $stats["cpe_new"]);
$graph->send($bsr_shortname.".ms.removed", $stats["cpe_removed"]);
$graph->send($bsr_shortname.".script.runtime", $runtime);
$graph->send($bsr_shortname.".script.warnings", $errorCount);

foreach ($ofbiz_stats as $action => $results) {
  foreach ($results as $result => $count) {
    $graph->send($bsr_shortname.".upload.$action.$result", $count);
  }
} 

//Push Full RF Statistics to Graphite (different prefix)
$graph2 = new GraphiteUtil(GRAPHITE_HOST, GRAPHITE_PORT, GRAPHITE_PREFIX.".cpe");
foreach ($ms_stats as $MAC => $ms) {
  foreach ($ms as $metric => $value) {
    $graph2->send($MAC.".$metric", $value);
  }
}

//Close check record
$DB->query("UPDATE bsr_check SET snmp_last_result = 'Status: $exit_status - Runtime: $runtime sec' WHERE ip = '$IP'");

$DB->close();
?>
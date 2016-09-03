#!/usr/bin/php
<?php 
// Fetch SNMP Data for Airspan BSR
// This script is called every 5 minutes by crontab.
require_once("/etc/rcs/airspan/settings.inc");

//require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/GraphiteUtil.class.inc");
require_once(ROOT."/util/LogUtil.class.inc");
require_once(ROOT."/util/SNMPUtil.class.inc");
require_once(ROOT."/util/Timer.class.inc");
require_once(ROOT."/util/Util.class.inc");

// Parameters
$IP = $argv[1];
LogUtil::info(MODULE, "SNMP check for Airspan BSR $IP (Statistics) has been requested.");

// Script started
Timer::start();

// Verify input
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

// SNMP Fetch
$cpe_stats = SNMPUtil::getData($IP, SNMP_COMMUNITY, OID_CPE_RF_STATS);
if (count($cpe_stats) == 0) {
	LogUtil::critical(MODULE, "SNMP ("+$IP+" : "+SNMP_COMMUNITY+") did not return a valid result for OID "+OID_CPE_RF_STATS);
	exit(1);
}

$ms_stats = array();
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

// Finish Run
$runtime = round(Timer::stop());

// Push Stats to Graphite
$graph = new GraphiteUtil(GRAPHITE_HOST, GRAPHITE_PORT, GRAPHITE_PREFIX.".stats");
// Script Summary
$graph->send($bsr_shortname.".script.cpe_count", count($ms_stats));
$graph->send($bsr_shortname.".script.runtime", $runtime);
// CPE Details
foreach ($ms_stats as $MAC => $ms) {
  foreach ($ms as $metric => $value) {
    $graph->send($bsr_shortname.".cpe.".$MAC.".$metric", $value);
  }
}
// BSR MODCOD Summary
$modcodTable = Util::summarizePerModcod($ms_stats);
foreach ($modcodTable as $key => $value) {
	$graph->send($bsr_shortname.".modcod.".$key, $value);
}

$DB->close();

exit(0);
?>
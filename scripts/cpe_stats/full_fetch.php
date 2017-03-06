#!/usr/bin/php
<?php 
// Fetch all BSRs from DB and start SNMP check for all.
// This script is called hourly (9 AM - 6 PM) by crontab (only).
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/LogUtil.class.inc");

$bsr = $DB->query("SELECT * FROM bsr_check");
while ($row = $bsr->fetch_assoc()) {
 	$execute_check = false;
 	if ($row["snmp_last_result"] == "RUNNING") {
 		if (time() - strtotime($row["snmp_last_check"]) > 24*60*60) {//TODO MAX_CHECK_INTERVAL = 24*60 //minutes
 			$execute_check = true;
 		} else {
 			LogUtil::warning(MODULE, "The check for Base Station ".$row["name"]." is still running. Please wait until check is completed.");
 		}
 	} else {
 		if (time() - strtotime($row["snmp_last_check"]) < MIN_CHECK_INTERVAL*60) {
 			LogUtil::warning(MODULE, "Previous check for Base Station ".$row["name"]." was at ".$row["snmp_last_check"].". Please wait ".MIN_CHECK_INTERVAL." minutes before retrying.");
 		} else {
 			$execute_check = true;
 		}
 	}
	 
 	if ($execute_check) {
 		exec("nohup ".ROOT."/scripts/cpe_stats/bsr_fetch.php ".$row["ip"]." > /dev/null 2>&1 &");
 	}
}
$bsr->free();    

$DB->close();
?>
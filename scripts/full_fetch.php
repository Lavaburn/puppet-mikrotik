#!/usr/bin/php
<?php 
// Fetch all BSRs from DB and start SNMP check for all.
// This script is called hourly (9 AM - 6 PM) by crontab (only).
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/LogUtil.class.inc");

$bsr = $DB->query("SELECT * FROM bsr_check");
while ($row = $bsr->fetch_assoc()) {
  if ($row["snmp_last_result"] == "RUNNING") {
    LogUtil::warning(MODULE, "The check for BSR ".$row["name"]." is still running. Will not start a new instance now!");

    if (time() - strtotime($row["snmp_last_check"]) > 24*60*60) {
      //Last valid check is more than 1 day old!
      LogUtil::critical(MODULE, "The last SNMP check for BSR ".$row["name"]." is more than 1 day old!");
      //TODO SENSU ALERT ?
      //TODO MAIL ??
    }
  } else {
     if (time() - strtotime($row["snmp_last_check"]) < MIN_CHECK_INTERVAL * 60) {
       //Previous check was less than x minutes ago
       LogUtil::warning(MODULE, "Previous check for BSR ".$row["name"]." was at ".$row["snmp_last_check"].". Will not start a new check now!");
     } else {
       exec("nohup ".ROOT."/scripts/bsr_fetch.php ".$row["ip"]." > /dev/null 2>&1 &");
     }
  }
}
$bsr->free();    

$DB->close();
?>
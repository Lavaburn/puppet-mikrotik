#!/usr/bin/php
<?php 
// Fetch all BSRs from DB and start SNMP check for all.
// This script is called every 5 minutes by crontab.
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/LogUtil.class.inc");

$bsr = $DB->query("SELECT * FROM bsr_check");
while ($row = $bsr->fetch_assoc()) {
	exec("nohup ".ROOT."/scripts/bsr_stats/bsr_fetch.php ".$row["ip"]." > /dev/null 2>&1 &"); 
}
$bsr->free();    

$DB->close();
?>
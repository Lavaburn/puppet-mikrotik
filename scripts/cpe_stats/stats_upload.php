#!/usr/bin/php
<?php 
// Upload all new RF Statistics to Ofbiz.
// This script is called daily (9 PM) by crontab (only).
require_once("/etc/rcs/airspan/settings.inc");

require_once(ROOT."/common/db.inc");

require_once(ROOT."/util/Curator.class.inc");
require_once(ROOT."/util/GraphiteUtil.class.inc");
require_once(ROOT."/util/LogUtil.class.inc");
require_once(ROOT."/util/Ofbiz.class.inc");
require_once(ROOT."/util/Timer.class.inc");

//Script started
Timer::start();

// SOAP Push
$ofbiz = new Ofbiz($DB, OFBIZ_SERVER, OFBIZ_PORT);
$stats = $ofbiz->pushRFstatistics();  

//Curator - Archive Outdated RF Statistics
$curator = new Curator($DB);
$archive_stats = $curator->archiveStatistics();

//Finish Run
$runtime = round(Timer::stop());

//Push Stats to Graphite
$graph = new GraphiteUtil(GRAPHITE_HOST, GRAPHITE_PORT, GRAPHITE_PREFIX.".config");
$graph->send("stats.count.days", $stats["days"]);
$graph->send("stats.count.cpes", $stats["cpes"]);
$graph->send("stats.count.records", $stats["records"]);
$graph->send("stats.status.success", $stats["upload"]["success"]);
$graph->send("stats.status.failure", $stats["upload"]["failure"]);
$graph->send("stats.runtime", $runtime);
$graph->send("stats.archive.records", $archive_stats["records"]);
$graph->send("stats.archive.days", $archive_stats["days"]);

$DB->close();
?>
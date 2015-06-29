#!/usr/bin/php
<?php
$time = microtime(true);

//Constants
define("ERPSERVER", "216.250.115.253");
define("SCRIPTDIR", "/etc/scripts/erp/");

//Includes
require_once(SCRIPTDIR.'lib/nusoap/nusoap.php');

//Persistence
$DB = new mysqli('tools.dmz.rcswimax.com', 'statistics', 'wimax2013juba', 'wimax_stats');
$soap = new soapclientnusoap('http://'.ERPSERVER.':8080/webtools/control/SOAPService/');

$RFstats = array();
$now = time() - 60*60*24;//1 day ago
$from = date("Y-m-d", $now)." 00:00:00";
$to = date("Y-m-d", $now)." 23:59:59";

echo "SELECT * FROM rf_stats WHERE check_time > '$from' and check_time < '$to'\n";

$result = $DB->query("SELECT * FROM rf_stats WHERE check_time > '$from' and check_time < '$to'");
while ($row = $result->fetch_array()) {
	$mac = $row["mac"];
	
	$RFstats[$mac][] = $row;
}
$result->free();

$fields = array("rssi_down", "rssi_up", "cinr_down", "cinr_up", "modulation_down", "modulation_up", "tx_power");

$fileName = "airspan_rf_".date("Ymd", $now).".csv";
$localFile = "/tmp/$fileName";

$i = 0;
$fp = fopen($localFile, "w");
fwrite($fp, "mac;bs;rssiDMin;rssiDMax;rssiDAvg;rssiUMin;rssiUMax;rssiUAvg;cinrDMin;cinrDMax;cinrDAvg;cinrUMin;cinrUMax;cinrUAvg;modDMin;modDMax;modDAvg;modUMin;modUMax;modUAvg;txPwrMin;txPwrMax;txPwrAvg\n");
foreach ($RFstats as $mac => $rows) {
	$line = "$mac;";
	
	$basestation = "";
	$min = array();
	$max = array();
	$sum = array();

	foreach ($rows as $row) {
		$basestation = $row["bs"];
		
		foreach ($fields as $field) {
			$value = $row[$field];
			if ($field == "modulation_down") {
				$value = $row[$field] + ($row["mimo"]==1?10:0);//1 - 8 of 11 - 18
			}
			
			if (!isset($min[$field]) || $value < $min[$field]) $min[$field] = $value;
			if (!isset($max[$field]) || $value > $max[$field]) $max[$field] = $value;
			$sum[$field] += $value;
		}
	}
	
	$line .= "$basestation";
	foreach ($fields as $field) {
		$line .= ";".$min[$field].";".$max[$field].";".round($sum[$field] / count($rows));
	}
	$line .= "\n";
	fwrite($fp, $line);
	$i++;
}
fclose($fp);

echo "$i lines in file.\n";

$remotePath = "/tmp/";
shell_exec("scp $localFile ".ERPSERVER.":$remotePath");

//Call Ofbiz
$params = array();
$params["fileName"] = $remotePath.$fileName;
$params["checkDate"] = date("Y-m-d", $now);
$result = $soap->call('uploadAirspanRFstats', $params);
if (!$result->result) {
	//ERROR
}
echo "Called uploadAirspanRFstats with params:\n";
print_r($params);
?>

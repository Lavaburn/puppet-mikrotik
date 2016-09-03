<?php 
require_once(ROOT."/util/LogUtil.class.inc");

$DB = new mysqli(DB_HOSTNAME, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
if ($DB->connect_errno) {
  $error = "Failed to connect to MySQL: (" . $DB->connect_errno . ") " . $DB->connect_error;  
  LogUtil::critical(MODULE, $error, true);  
  exit(1);
}
?>
<?php 
class Curator {
  private $database;
	
  public function __construct($database) {
    $this->database = $database;
  }
  
  public function archiveStatistics() {
    $date_1year = mktime(0, 0, 0, date("n") - 1, 1, date("Y") - 1);
    $date_1month = mktime(0, 0, 0, date("n") - 1, 1, date("Y"));
    
    // Remove Archive Table if one year old table exists
    $archive_table = "archive_rf_stats_".date("Y_m", $date_1year);
    $archive_table_test = $this->database->query("SELECT 1 FROM $archive_table");
    if ($archive_table_test !== FALSE) {
      LogUtil::info(MODULE, "Found 1-year old archive table: $archive_table. Deleting the table now.");
      $res = $this->database->query("DROP TABLE $archive_table");
      if (!$res) {
        LogUtil::critical(MODULE, "Failed to remove table: $archive_table !");
      }
    }
    
    // Move uploaded data older than 1 month to (monthly) archive table (auto-create table) 
    $count = 0;
    $unique_days = array();
    $statistics = $this->database->query("SELECT * FROM rf_stats WHERE uploaded = '1' AND check_time < '".date("Y-m-d 00:00:00", $date_1month)."'");
    while ($row = $statistics->fetch_assoc()) {
      //Time
      $time = strtotime($row["check_time"]);      
      $day = date("Y-m-d", $time);
      $month = date("Y_m", $time);
      
      //Create Table (if not yet exists)
      $archive_table = "archive_rf_stats_".$month;
      $archive_table_test = $this->database->query("SELECT 1 FROM $archive_table");
      if ($archive_table_test === FALSE) {
        $this->database->query("
          CREATE TABLE IF NOT EXISTS $archive_table (
            `mac` varchar(20) NOT NULL,
            `bsr_ip` varchar(20) NOT NULL,
            `check_time` datetime NOT NULL,
            `rssi_down` double NOT NULL,
            `rssi_up` double NOT NULL,
            `cinr_down` double NOT NULL,
            `cinr_up` double NOT NULL,
            `modulation_down` int(11) NOT NULL,
            `modulation_up` int(11) NOT NULL,
            `mimo` int(11) NOT NULL,
            `tx_power` double NOT NULL,
            `uploaded` tinyint(1) NOT NULL,
            PRIMARY KEY (`mac`,`check_time`)
          ) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
      }
      
      //Move Record
      $condition = "WHERE mac = '".$row["mac"]."' AND check_time = '".$row["check_time"]."'";
      $this->database->query("INSERT INTO $archive_table SELECT * FROM rf_stats $condition");
      $this->database->query("DELETE FROM rf_stats $condition");
      
      //Stats
      if (!in_array($day, $unique_days)) $unique_days[] = $day;      
      $count++;      
    }
    $statistics->free();
    
    $stats = array(
      "records" => $count,   
      "days"    => count($unique_days),
    );

    return $stats;
  }
}
?>
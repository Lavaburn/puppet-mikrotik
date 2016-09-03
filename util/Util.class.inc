<?php 
class Util {
  public static function convertMAC($MAC_decimal) {
    $hex = "";
    $parts = explode("." , $MAC_decimal);
    foreach ($parts as $part) {
      if ($hex != "") $hex .= ":";
      $hex .= ($part<16?"0":"").strtoupper(dechex($part));
    }
    return $hex;
  }
  
  public static function summarizePerModcod($ms_stats) {
  	$modcodTable = array();
  	foreach ($ms_stats as $MAC => $stats) {
  		self::increase($modcodTable, "raw.uplink.0.".$stats["modulation_up"]);
  		self::increase($modcodTable, "raw.downlink.".$stats["mimo"].".".$stats["modulation_down"]);
  		
  		$mimo = self::convertMimo($stats["mimo"]);
  		$modulation_up = self::convertModcod($stats["modulation_up"]);
  		$modulation_down = self::convertModcod($stats["modulation_down"]);
  		
  		self::increase($modcodTable, "x.uplink.matrix_a.".$modulation_up);
  		self::increase($modcodTable, "x.downlink.".$mimo.".".$modulation_down);
  	}
  	return $modcodTable;
  }
  
  private static function increase(&$array, $key, $value = 1) {
  	if (!array_key_exists($key, $array)) {
  		$array[$key] = 0;
  	}
  	$array[$key] = $array[$key] + $value;
  }

  private static function convertMimo($raw) {
  	switch ($raw) {
  		case 0: 	return "matrix_a";
  		case 1: 	return "matrix_b";
  		default: 	return "unknown";
  	}  	
  }  

  private static function convertModcod($raw) {
  	switch ($raw) {
  		case 1: 	return "qpsk_1_2";
  		case 2: 	return "qpsk_3_4";
  		case 3: 	return "16qam_1_2";
  		case 4: 	return "16qam_3_4";
  		case 5: 	return "64qam_1_2";
  		case 6: 	return "64qam_2_3";
  		case 7: 	return "64qam_3_4";
  		case 8: 	return "64qam_5_6";
  		default: 	return "unknown";
  	}  	
  }  
}
?>
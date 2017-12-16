<?php 
class Airspan {  
  public static function parseMsStats($cpeStats) {
  	$msStats = array();
  	foreach ($cpeStats as $oidSuffix => $value) {
  		$oid_suffix_parts = explode("." , $oidSuffix);
  		$index = $oid_suffix_parts[0];
  	
  		$macDecimal = preg_replace("/^$index\.1\./", "", $oidSuffix);
  		$mac = Util::convertMAC($macDecimal);
  		
  		$msStats = $this->updateStats($msStats, $mac, $index, $value);
  	}
  	return $msStats;
  }
  
  private function updateStats($msStats, $mac, $index, $value) {  	
  	switch ($index) {
  		case 1:		$msStats[$mac]["rssi_down"] = $value - 123;
  					break;
  		case 2:		$msStats[$mac]["rssi_up"] = $value / 4;
  					break;
  		case 12:	$msStats[$mac]["cinr_down"] = $value / 4;
  					break;
  		case 5:		$msStats[$mac]["cinr_up"] = $value / 4;
  					break;
  		case 14:	$msStats[$mac]["modulation_down"] = $value + 1;//0 = QPSK1/2, 7 = 64QAM5/6
  					break;
  		case 6:		$msStats[$mac]["modulation_up"] = $value;// 8 = 64QAM5/6, 1 = QPSK1/2
  					break;
  		case 11:	$msStats[$mac]["mimo"] = $value;//0 = MatrixA, 1 = MatrixB
  					break;
  		case 13:	$msStats[$mac]["tx_power"] = $value;
  					break;
  		default: 	//Do Nothing
  	}
  	return $msStats;
  }
}
?>
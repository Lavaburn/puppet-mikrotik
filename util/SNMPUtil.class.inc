<?php 
snmp_set_oid_numeric_print(true);                    // PHP 4.3.0
snmp_set_oid_output_format(SNMP_OID_OUTPUT_NUMERIC); // PHP 5.2.0

//define("OID_SYSTEM",				                  "1.3.6.1.2.1.1");
define("OID_PRIVATE", 				                "1.3.6.1.4.1");

define("OID_AIRSPAN",               OID_PRIVATE.	".989.1.16");

define("OID_CPE_RF_STATS", 		    OID_AIRSPAN.	".2.9.2.1");
define("OID_BS_VLAN_SERVICE_CLASS", OID_AIRSPAN.	".5.4.1.2.1.16"); // 3 = multicast group
define("OID_BS_VLAN_TAGGED", 	    OID_AIRSPAN.	".5.4.2.4.1.2.4");// 0 = tagged
define("OID_VLAN_CPE", 		        OID_AIRSPAN.	".5.4.2");

define("OID_CPE_CONFIG_PVID", 	    OID_VLAN_CPE.	".1.1.4.1");
define("OID_CPE_CONFIG_TYPE", 	    OID_VLAN_CPE.	".1.1.6.1");
define("OID_CPE_CONFIG_TAGGED", 	OID_VLAN_CPE.	".2.1.3.1");

class SNMPUtil {
  public static function getData($ipAddress, $community, $oid) {
    $result = array();
    
    $raw_data = @snmprealwalk($ipAddress, $community, $oid);
    if (!empty($raw_data)) {
      foreach ($raw_data as $rawId => $value) {
        $clean_id = self::clean_id($rawId, $oid);
        $clean_value = self::clean_value($value);      
        $result[$clean_id] = $clean_value;
      }
      return $result;
    }
    
    LogUtil::warning(MODULE, "Could not retrieve SNMP data for $ipAddress ($community) with OID: $oid");    
    return $result;
  }
  
  private static function clean_id($rawId, $oid) {
    if (preg_match("/^SNMPv2-SMI::enterprises/", $rawId)) {
      $oid2 = preg_replace("/^".OID_PRIVATE."/", "SNMPv2-SMI::enterprises", $oid);
    }
    
    if (preg_match("/^iso/", $rawId)) {
      $oid2 = preg_replace("/^1/", "iso", $oid);
    }
    
    if (preg_match("/^.1/", $rawId)) {
      $oid2 = $oid;      
    }
    
    return preg_replace("/^\.$oid2\./", "", $rawId);
  }
  
  private static function clean_value($rawValue) {
    $rawValue = preg_replace("/INTEGER: /", "", $rawValue);
	$rawValue = preg_replace("/Counter32: /", "", $rawValue);
	$rawValue = preg_replace("/IpAddress: /", "", $rawValue);
	$rawValue = preg_replace("/Hex-STRING: /", "", $rawValue);
	
	if (preg_match("/STRING: /", $rawValue)) {
		$rawValue = preg_replace("/STRING: /", "", $rawValue);
		$rawValue = preg_replace("/\"/", "", $rawValue);
	}
	
	return $rawValue;
  }
}
?>
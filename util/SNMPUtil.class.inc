<?php 
snmp_set_oid_numeric_print(true);// PHP 4 ?
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
  public static function getData($ip, $community, $oid) {
    $result = array();
    
    $raw_data = @snmprealwalk($ip, $community, $oid);
    if (!empty($raw_data)) {
      foreach ($raw_data as $id => $value) {
        $clean_id = self::clean_id($id, $oid);
        $clean_value = self::clean_value($value);      
        $result[$clean_id] = $clean_value;
      }
    } else {
      LogUtil::warning(MODULE, "Could not retrieve SNMP data for $ip ($community) with OID: $oid");
    }
    return $result;
  }
  
  private static function clean_id($raw_id, $OID) {
    if (preg_match("/^SNMPv2-SMI::enterprises/", $raw_id)) {
      $OID2 = preg_replace("/^".OID_PRIVATE."/", "SNMPv2-SMI::enterprises", $OID);
    }
    
    if (preg_match("/^iso/", $raw_id)) {
      $OID2 = preg_replace("/^1/", "iso", $OID);
    }
    
    if (preg_match("/^.1/", $raw_id)) {
      $OID2 = $OID;      
    }
    
    $id = preg_replace("/^\.$OID2\./", "", $raw_id);   
    return $id;
  }
  
  private static function clean_value($raw_value) {
    $raw_value = preg_replace("/INTEGER: /", "", $raw_value);
	$raw_value = preg_replace("/Counter32: /", "", $raw_value);
	$raw_value = preg_replace("/IpAddress: /", "", $raw_value);
	$raw_value = preg_replace("/Hex-STRING: /", "", $raw_value);
	
	if (preg_match("/STRING: /", $raw_value)) {
		$raw_value = preg_replace("/STRING: /", "", $raw_value);
		$raw_value = preg_replace("/\"/", "", $raw_value);
	}
	
	return $raw_value;
  }
}
?>
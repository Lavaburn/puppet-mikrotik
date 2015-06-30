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
}
?>
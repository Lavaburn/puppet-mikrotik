<?php 
class GraphiteUtil {
  private $hostname;
  private $port;
  private $prefix;
  
  public function __construct($hostname, $port, $prefix) {
    $this->hostname = $hostname;
    $this->port = $port;
    $this->prefix = $prefix;
  }
    
  public function send($name, $value) {
    $line = $this->prefix.".$name $value ".time()."\n";
    
    $fp = fsockopen($this->hostname, $this->port, $err, $errc, 1);// hostname = udp:// ?
    fwrite($fp, $line);    
    fclose($fp);
  }
}
?>
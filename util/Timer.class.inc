<?php 
class Timer {
  private static $startTime;
  
  public static function start() {
    self::$startTime = microtime(true);
  }

  public static function stop() {
    $seconds = microtime(true) - self::$startTime;
    return $seconds;
  }
}
?>
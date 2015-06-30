<?php 
class LogUtil {
  public static function critical($module, $message, $echo = false) {
    $priority = LOG_CRIT;
    return self::log($priority, $module, $message, $echo);
  }

  public static function warning($module, $message, $echo = false) {
    $priority = LOG_WARNING;
    return self::log($priority, $module, $message, $echo);
  }

  public static function info($module, $message, $echo = false) {
    $priority = LOG_INFO;
    return self::log($priority, $module, $message, $echo);
  }

  public static function log($priority, $module, $message, $echo = false) {
    if (DEBUG || $priority < LOG_DEBUG) {
      syslog($priority, "[$module] $message");
    }
    if (DEBUG && $echo) {
      echo "[$module] $message\n";
    }
    return $priority;
  }
}
?>
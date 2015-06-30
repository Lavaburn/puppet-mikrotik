CREATE TABLE IF NOT EXISTS `bsr_check` (
  `name` varchar(50) NOT NULL,
  `shortname` varchar(20) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `snmp_last_check` datetime DEFAULT NULL,
  `snmp_last_result` varchar(255) DEFAULT NULL,
  `cpe_online` int(11) DEFAULT NULL,
  `cpe_updated` int(11) DEFAULT NULL,
  `cpe_new` int(11) DEFAULT NULL,
  `cpe_removed` int(11) DEFAULT NULL,
  PRIMARY KEY (`ip`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `deleted_ms_config` (
  `mac` varchar(20) NOT NULL,
  `vlan_type` int(11) NOT NULL,
  `default_vlan` int(11) NOT NULL,
  `bsr_ip` varchar(20) NOT NULL,
  `last_checked` datetime NOT NULL,
  `updated` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mac`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `deleted_ms_vlan_config` (
  `mac` varchar(20) NOT NULL,
  `vlan` int(11) NOT NULL,
  `tagged` int(11) NOT NULL,
  `last_checked` datetime NOT NULL,
  `updated` tinyint(1) NOT NULL,
  PRIMARY KEY (`mac`,`vlan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `deleted_rf_stats` (
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ms_config` (
  `mac` varchar(20) NOT NULL,
  `vlan_type` int(11) NOT NULL,
  `default_vlan` int(11) NOT NULL,
  `bsr_ip` varchar(20) NOT NULL,
  `last_checked` datetime NOT NULL,
  `updated` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mac`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ms_vlan_config` (
  `mac` varchar(20) NOT NULL,
  `vlan` int(11) NOT NULL,
  `tagged` int(11) NOT NULL,
  `last_checked` datetime NOT NULL,
  `updated` tinyint(1) NOT NULL,
  PRIMARY KEY (`mac`,`vlan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rf_stats` (
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
CREATE TABLE IF NOT EXISTS `archive_cpe_config` (
  `mac` varchar(20) NOT NULL,
  `vlan_type` int(11) NOT NULL,
  `default_vlan` int(11) NOT NULL,
  `updated` date NOT NULL,
  `uploaded` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`mac`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `archive_cpe_vlan_list` (
  `mac` varchar(20) NOT NULL,
  `vlan` int(11) NOT NULL,
  `tagged` int(11) NOT NULL,
  `updated` date NOT NULL,
  PRIMARY KEY  (`mac`,`vlan`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `archive_rf_stats` (
  `mac` varchar(20) NOT NULL,
  `bs` varchar(20) NOT NULL,
  `check_time` datetime NOT NULL,
  `rssi_down` double NOT NULL,
  `rssi_up` double NOT NULL,
  `cinr_down` double NOT NULL,
  `cinr_up` double NOT NULL,
  `modulation_down` int(11) NOT NULL,
  `modulation_up` int(11) NOT NULL,
  `mimo` int(11) NOT NULL,
  `tx_power` double NOT NULL,
  PRIMARY KEY  (`mac`,`check_time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `basestations` (
  `name` varchar(100) NOT NULL,
  `ip` varchar(20) NOT NULL,
  `type` varchar(20) NOT NULL,
  PRIMARY KEY  (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `config_errors` (
  `mac` varchar(20) NOT NULL,
  `added` date NOT NULL,
  `error` varchar(255) NOT NULL,
  PRIMARY KEY  (`mac`,`added`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `cpe_config` (
  `mac` varchar(20) NOT NULL,
  `vlan_type` int(11) NOT NULL,
  `default_vlan` int(11) NOT NULL,
  `updated` date NOT NULL,
  `uploaded` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`mac`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `cpe_vlan_list` (
  `mac` varchar(20) NOT NULL,
  `vlan` int(11) NOT NULL,
  `tagged` int(11) NOT NULL,
  `updated` date NOT NULL,
  PRIMARY KEY  (`mac`,`vlan`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rf_stats` (
  `mac` varchar(20) NOT NULL,
  `bs` varchar(20) NOT NULL,
  `check_time` datetime NOT NULL,
  `rssi_down` double NOT NULL,
  `rssi_up` double NOT NULL,
  `cinr_down` double NOT NULL,
  `cinr_up` double NOT NULL,
  `modulation_down` int(11) NOT NULL,
  `modulation_up` int(11) NOT NULL,
  `mimo` int(11) NOT NULL,
  `tx_power` double NOT NULL,
  PRIMARY KEY  (`mac`,`check_time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

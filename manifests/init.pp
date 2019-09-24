class mikrotik  {
  # Dependencies for running the custom Type/Provider
  file { '/usr/src/mtik-4.0.4.gem':
    ensure => 'file',
    source => 'puppet:///modules/mikrotik/mtik-4.0.4.gem',
  }
  ->
  package { 'mtik':
    ensure   => 'present',
    provider => 'puppet_gem',
    source   => '/usr/src/mtik-4.0.4.gem',
  }

  # We could use classes/defines to set up devices.conf
}

class mikrotik (
  $version = '4.1.2'
) {
  # mtik-4.0.4 => Mikrotik pre 6.43
  # mtik 4.1.2 => MUST BE USED FROM 6.45.1

  # Dependencies for running the custom Type/Provider
  file { "/usr/src/mtik-${version}.gem":
    ensure => 'file',
    source => "puppet:///modules/mikrotik/mtik-${version}.gem",
  }
  ->
  package { 'mtik':
    ensure   => 'present',
    provider => 'puppet_gem',
    source   => "/usr/src/mtik-${version}.gem",
  }

  # We could use classes/defines to set up devices.conf
}

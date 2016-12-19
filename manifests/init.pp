class mikrotik  {
  # Dependencies for running the custom Type/Provider
  package { 'mtik':
    ensure   => 'present',
    provider => 'puppet_gem',
  }

  # We could use classes/defines to set up devices.conf
}

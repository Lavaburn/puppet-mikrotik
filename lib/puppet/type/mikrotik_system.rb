Puppet::Type.newtype(:mikrotik_system) do
  apply_to_all
  
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -system-'
    isnamevar
  end

  newproperty(:identity) do
    desc 'The System Identity Name.'
  end
  
  newproperty(:timezone) do
    desc 'The Clock timezone.'
  end
  
  newproperty(:ntp_enabled) do
    desc 'Whether to enable NTP Client.'
  end

  newproperty(:ntp_primary) do
    desc 'The primary server for the NTP Client.'
  end

  newproperty(:ntp_secondary) do
    desc 'The secondary server for the NTP Client.'
  end
end

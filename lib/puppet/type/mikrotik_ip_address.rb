Puppet::Type.newtype(:mikrotik_ip_address) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used
  
  newparam(:address) do
    desc 'SNMP community name'
    isnamevar
  end
  
  newproperty(:interface) do
    desc 'Interface to attach the IP address on.'
  end

  # Not used much?
  #broadcast netmask network
end

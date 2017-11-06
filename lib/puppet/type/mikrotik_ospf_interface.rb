Puppet::Type.newtype(:mikrotik_ospf_interface) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'OSPF Interface'
    isnamevar
  end
  
  newproperty(:cost) do
    desc 'The Cost of the OSPF interface.'
  end
  
  newproperty(:priority) do
    desc 'The Priority of the OSPF interface.'
  end
  
  newproperty(:authentication) do
    desc 'The authentication type (none, simple, md5)'
    newvalues(:none, :simple, :md5)
    defaultto :none
  end
  
  newproperty(:authentication_key) do # authentication-key
    desc 'The key used for authentication.'
  end
  
  newproperty(:authentication_key_id) do # authentication-key-id
    desc 'Key ID used to calculate message digest (MD5 authentication). Common for all routers in area.'
  end
  
  newproperty(:network_type) do # network-type
    desc 'The network type (default, broadcast, nbma, point-to-point, ptmp)'
    newvalues(:default, :broadcast, :nbma, 'point-to-point', :ptmp)
    defaultto :broadcast
  end
  
  newproperty(:passive) do
    desc 'Whether the interface is passive (not participating in OSPF)'
    newvalues(false, true)
    defaultto true
  end
  
  newproperty(:use_bfd) do # use-bfd
    desc 'Whether to enable BFD on the interface for the OSPF process'
    newvalues(false, true)
    defaultto true
  end
end

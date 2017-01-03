Puppet::Type.newtype(:mikrotik_ospf_interface) do
  apply_to_device

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
  
#  authentication
#  authentication-key
#  authentication-key-id
#  network-type
#  passive
#  use-bfd
end

Puppet::Type.newtype(:mikrotik_ospf_network) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'OSPF Network (Subnet)'
    isnamevar
  end
  
  newproperty(:area) do
    desc 'The OSPF Area this network belongs to.'
  end

  newproperty(:comment) do
    desc 'A comment that describes this network'
  end
end

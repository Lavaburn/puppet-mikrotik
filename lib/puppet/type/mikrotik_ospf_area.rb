Puppet::Type.newtype(:mikrotik_ospf_area) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'OSPF Area Name'
    isnamevar
  end
  
  newproperty(:area_id) do
    desc 'The OSPF Area ID (IP).'
  end
  
  newproperty(:instance) do
    desc 'The OSPF instance this area belongs to.'
  end

  newproperty(:area_type) do
    desc 'The type of the OSPF Area.'
    newvalues('default', 'stub', 'nssa')
  end
end

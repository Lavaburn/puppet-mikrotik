Puppet::Type.newtype(:mikrotik_ospfv3_area) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'OSPFv3 Area Name'
    isnamevar
  end
  
  newproperty(:area_id) do
    desc 'The OSPFv3 Area ID (IP).'
  end
  
  newproperty(:instance) do
    desc 'The OSPFv3 instance this area belongs to.'
  end

  newproperty(:area_type) do
    desc 'The type of the OSPFv3 Area.'
    newvalues('default', 'stub', 'nssa')
  end
end

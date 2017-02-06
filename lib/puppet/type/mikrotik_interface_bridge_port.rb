Puppet::Type.newtype(:mikrotik_interface_bridge_port) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used
  
  newparam(:interface) do
    desc 'Name of the interface'
    isnamevar
  end

  newproperty(:bridge) do
    desc 'The bridge interface the respective interface is grouped in'
  end
  
  # Not frequently used settings:
  ## priority -- The priority of the interface in comparison with other going to the same subnet
  ## path-cost -- Path cost to the interface, used by STP to determine the 'best' path
  ## horizon --   
  ## edge -- 
  ## point-to-point -- 
  ## external-fdb -- 
  ## auto-isolate -- 
end

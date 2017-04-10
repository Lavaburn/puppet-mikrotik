Puppet::Type.newtype(:mikrotik_graph_interface) do
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'The interface name (or "all")'
    isnamevar
  end
  
  newproperty(:allow) do
    desc 'The IP/Subnet to allow access to the graphs.'
    defaultto '0.0.0.0/0'
  end

  newproperty(:store_on_disk) do
    desc 'Whether to store the graphs on disk.'
    newvalues(true, false)
    defaultto true    
  end
end

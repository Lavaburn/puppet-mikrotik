Puppet::Type.newtype(:mikrotik_graph_resource) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
    
  newparam(:name) do
    desc 'Name should be -resource-'
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

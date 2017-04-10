Puppet::Type.newtype(:mikrotik_graph_queue) do
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'The simple queue name (or "all")'
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

  newproperty(:allow_target) do
    desc 'Whether to allow access to web graphing from IP range specified in target-address parameter'
    newvalues(true, false)
    defaultto true    
  end
end

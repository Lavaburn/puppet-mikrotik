Puppet::Type.newtype(:mikrotik_dns) do
  apply_to_device

  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -dns-'
    isnamevar
  end

  newproperty(:servers, :array_matching => :all) do
    desc 'The DNS servers that the router will use to lookup names.'
  end
  
  newproperty(:allow_remote_requests) do
    desc 'Whether to allow incoming DNS requests (not router-local).'
  end
end

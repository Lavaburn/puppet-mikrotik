Puppet::Type.newtype(:mikrotik_ipv6_settings) do
  apply_to_all
  
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -ipv6-'
    isnamevar
  end

  newproperty(:forward) do
    desc 'Whether to enable IPv6 Forwarding.'
    newvalues(true, false)
  end
  
  newproperty(:accept_redirects) do
    desc 'Whether to accept redirects.'
    newvalues(true, false)
  end

  newproperty(:accept_router_advertisements) do
    desc 'Whether to accept RAs.'
    newvalues('no', 'yes', 'yes-if-forwarding-disabled')
  end

  newproperty(:max_neighbor_entries) do
    desc 'Maximum neighbors. Default: 8192'
  end
end

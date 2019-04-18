Puppet::Type.newtype(:mikrotik_ipv6_pool) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'IPv6 pool name'
    isnamevar
  end

  newproperty(:prefix) do
    desc 'IPv6 Prefix (parent subnet)'
  end
  
  newproperty(:prefix_length) do
    desc 'Prefix Length to allocate from pool. Default = 64'
  end
end

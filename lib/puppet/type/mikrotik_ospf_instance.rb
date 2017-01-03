Puppet::Type.newtype(:mikrotik_ospf_instance) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'OSPF Instance name'
    isnamevar
  end

  newproperty(:router_id) do
    desc 'The Router ID.'
  end
  
  newproperty(:distribute_default) do
    desc 'Whether to redistribute default routes to OSPF.'
    newvalues('never', 'if-installed-as-type-1', 'if-installed-as-type-2', 'always-as-type-1', 'always-as-type-2')
  end
    
  newproperty(:redistribute_connected) do
    desc 'Whether to redistribute connected routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end

  newproperty(:redistribute_static) do
    desc 'Whether to redistribute static routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end
  
  newproperty(:redistribute_ospf) do
    desc 'Whether to redistribute OSPF routes from other instances to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end
  
  newproperty(:redistribute_bgp) do
    desc 'Whether to redistribute BGP routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end

  newproperty(:in_filter) do
    desc 'The input filter applying on this instance.'
  end

  newproperty(:out_filter) do
    desc 'The output filter applying on this instance.'
  end

  newproperty(:metric_default) do
    desc 'The metric to use when redistributing default routes on this instance.'
  end

  newproperty(:metric_connected) do
    desc 'The metric to use when redistributing connected routes on this instance.'
  end

  newproperty(:metric_static) do
    desc 'The metric to use when redistributing static routes on this instance.'
  end

  newproperty(:metric_bgp) do
    desc 'The metric to use when redistributing BGP routes on this instance.'
  end

  newproperty(:metric_ospf) do
    desc 'The metric to use when redistributing OSPF routes from other instances on this instance.'
  end
end

Puppet::Type.newtype(:mikrotik_bgp_instance) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'BGP Instance name'
    isnamevar
  end
  
  newproperty(:as) do
    desc 'The Autonomous System (AS) Number.'
  end

  newproperty(:router_id) do
    desc 'The Router ID.'
  end
    
  newproperty(:redistribute_connected) do
    desc 'Whether to redistribute connected routes to BGP.'
    newvalues(true, false)
  end

  newproperty(:redistribute_static) do
    desc 'Whether to redistribute static routes to BGP.'
    newvalues(true, false)
  end
  
  newproperty(:redistribute_ospf) do
    desc 'Whether to redistribute OSPF routes to BGP.'
    newvalues(true, false)
  end
  
  newproperty(:redistribute_bgp) do
    desc 'Whether to redistribute BGP routes from other instances to BGP.'
    newvalues(true, false)
  end

  newproperty(:out_filter) do
    desc 'The output filter applying to all peers on this instance.'
  end

  newproperty(:client_to_client_reflection) do
    desc 'Whether to enable Client-to-Client Reflection.'
    newvalues(true, false)
  end

  newproperty(:routing_table) do
    desc 'The routing table this instance belongs to.'
  end
end

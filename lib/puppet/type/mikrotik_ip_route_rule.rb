Puppet::Type.newtype(:mikrotik_ip_route_rule) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used
  
  newparam(:name) do
    desc 'Rule description'
    isnamevar
  end

  newproperty(:src_address) do
    desc 'Source Address'
  end

  newproperty(:dst_address) do
    desc 'Destination Address'
  end

  newproperty(:routing_mark) do
    desc 'Routing mark set by firewall mangle'
  end

  newproperty(:interface) do
    desc 'Interface of incoming traffic'
  end

  newproperty(:action) do
    desc 'Action to take with selected traffic'
    newvalues(:lookup, :drop, :unreachable)
  end

  newproperty(:table) do
    desc 'Table to lookup routes in if action == "lookup"'
  end
  
#  newproperty(:sequence) do
#    desc 'Ordering of the rule'
#  end
end

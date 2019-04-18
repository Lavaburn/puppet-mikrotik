Puppet::Type.newtype(:mikrotik_ipv6_route) do
  apply_to_all
  
  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.create  
    end
    
    newvalue(:absent) do
      provider.destroy
    end
    
    newvalue(:enabled) do
      provider.create  
      provider.setState(:enabled)      
    end

    newvalue(:disabled) do
      provider.create  
      provider.setState(:disabled)
    end

    def retrieve
      provider.getState
    end
    
    def insync?(is)
      @should.each { |should| 
        case should
          when :present
            return (provider.getState != :absent)
          when :absent
            return (provider.getState == :absent)
          when :enabled
            return (provider.getState == :enabled)
          when :disabled
            return (provider.getState == :disabled)
        end
      }      
    end
  end
  
  newparam(:name) do
    desc 'Route description'
    isnamevar
  end

  newproperty(:dst_address) do
    desc 'Destination address'
  end
  
  newproperty(:gateway) do
    desc 'Gateway address'
  end

  newproperty(:check_gateway) do
    desc 'Whether to check nexthop with ARP or Ping request.'
    newvalues(:ping)
  end

  newproperty(:type) do
    desc 'Route type'
    newvalues('unicast', 'unreachable')
  end

  newproperty(:distance) do
    desc 'Administrative distance of the route'
  end

  newproperty(:scope) do
    desc 'Route Scope'
  end

  newproperty(:target_scope) do
    desc 'Target Route Scope'
  end

  newproperty(:bgp_as_path) do
    desc 'AS Path for BGP (advertisement ?)'
  end

  newproperty(:bgp_local_pref) do
    desc 'Local Preference for BGP (advertisement ?)'
  end

  newproperty(:bgp_prepend) do
    desc 'Prepend for BGP (advertisement ?)'
  end

  newproperty(:bgp_med) do
    desc 'MED for BGP (advertisement ?)'
  end

  newproperty(:bgp_atomic_aggregate) do
    desc 'Atomic Aggregate for BGP (advertisement ?)'
  end

  newproperty(:bgp_origin) do
    desc 'Origin for BGP (advertisement ?)'
  end

  newproperty(:route_tag) do
    desc 'Route Tag (?)'
  end

  newproperty(:bgp_communities) do
    desc 'BGP Communities for BGP (advertisement ?)'
  end  
end

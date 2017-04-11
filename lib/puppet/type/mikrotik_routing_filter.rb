Puppet::Type.newtype(:mikrotik_routing_filter) do
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
      provider.setState(:enabled)      
    end

    newvalue(:disabled) do
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
    desc 'Filter description'
    isnamevar
  end

  newproperty(:chain) do
    desc 'Filter Chain'
  end

  # Matchers
  newproperty(:prefix) do
    desc 'Match Prefix'
  end
  
  newproperty(:prefix_length) do
    desc 'Match Prefix length'
  end
  
  newproperty(:match_chain) do
    desc 'Match Chain'
  end
  
  newproperty(:protocols, :array_matching => :all) do
    desc 'Match Protocols'
    
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:distance) do
    desc 'Match Distance'
  end
  
  newproperty(:scope) do
    desc 'Match Scope'
  end
  
  newproperty(:target_scope) do
    desc 'Match Target scope'
  end
  
  newproperty(:pref_src) do
    desc 'Match Preferred source'
  end
  
  newproperty(:routing_mark) do
    desc 'Match Routing mark'
  end
  
  newproperty(:route_comment) do
    desc 'Match Route comment'
  end
  
  newproperty(:route_tag) do
    desc 'Match Route tag'
  end
  
  newproperty(:route_targets, :array_matching => :all) do
    desc 'Match Route targets'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:sites_of_origin, :array_matching => :all) do
    desc 'Match Sites of origin'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:address_families, :array_matching => :all) do
    desc 'Match Address families'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:ospf_type) do
    desc 'Match OSPF type'
    newvalues('external-type-1', 'external-type-2', 'inter-area', 'intra-area', 'nssa-external-type-1', 'nssa-external-type-2')
  end
  
  newproperty(:invert_match) do
    desc 'Whether to invert match'
  end

  # BGP Matchers
  newproperty(:bgp_as_path) do
    desc 'Match BGP AS path'
  end
  
  newproperty(:bgp_as_path_length) do
    desc 'Match BGP AS path length'
  end
  
  newproperty(:bgp_weight) do
    desc 'Match BGP weight'
  end
  
  newproperty(:bgp_local_pref) do
    desc 'Match BGP local preference'
  end
  
  newproperty(:bgp_med) do
    desc 'Match BGP MED'
  end
  
  newproperty(:bgp_atomic_aggregate) do
    desc 'Match BGP atomic aggregate'
    newvalues('present', 'absent')
  end
  
  newproperty(:bgp_origins, :array_matching => :all) do
    desc 'Match BGP origins'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:locally_originated_bgp) do
    desc 'Match only locally originated BGP'
    newvalues('yes', 'no')
  end

  newproperty(:bgp_communities, :array_matching => :all) do
    desc 'Match BGP communities'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  # Actions
  newproperty(:action) do
    desc 'Action to take if matched'
    newvalues('accept', 'jump', 'discard', 'log', 'reject', 'passthrough', 'return')
  end
  
  newproperty(:jump_target) do
    desc 'Chain to jump to if action is jump and filter is matched'
  end
  
  newproperty(:set_distance) do
    desc 'Set distance if matched'
  end
  
  newproperty(:set_scope) do
    desc 'Set scope if matched'
  end
  
  newproperty(:set_target_scope) do
    desc 'Set target scope if matched'
  end
  
  newproperty(:set_pref_src) do
    desc 'Set preferred source if matched'
  end
  
  newproperty(:set_in_nexthops, :array_matching => :all) do
    desc 'Set inbound nexthop if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:set_in_nexthops_direct, :array_matching => :all) do
    desc 'Set inbound nexthop (interface) if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:set_out_nexthop) do
    desc 'Set outbound nexthop if matched'
  end
  
  newproperty(:set_routing_mark) do
    desc 'Set routing mark if matched'
  end
  
  newproperty(:set_route_comment) do
    desc 'Set route comment if matched'
  end
  
  newproperty(:set_check_gateway) do
    desc 'Whether to check gateway if matched'
    newvalues('ping', 'arp', 'none')
  end
  
  newproperty(:set_disabled) do
    desc 'Whether to set route disabled if matched'
    newvalues('yes', 'no')
  end
  
  newproperty(:set_type) do
    desc 'Set route type if matched'
    newvalues('unicast', 'blackhole', 'prohibit', 'unreachable')
  end
  
  newproperty(:set_route_tag) do
    desc 'Set route tag if matched'
  end
  
  newproperty(:set_use_te_nexthop) do
    desc 'Set MPLS TE nexthop if matched'
    newvalues('yes', 'no')
  end
  
  newproperty(:set_route_targets, :array_matching => :all) do
    desc 'Set route targets if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:append_route_targets, :array_matching => :all) do
    desc 'Append route targets if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:set_site_of_origin, :array_matching => :all) do
    desc 'Set site of origin if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  # BGP Actions
  newproperty(:set_bgp_weight) do
    desc 'Set BGP weight if matched'
  end
  
  newproperty(:set_bgp_local_pref) do
    desc 'Set BGP local preference if matched'
  end
  
  newproperty(:set_bgp_prepend) do
    desc 'Set BGP AS path count prepend if matched'
  end
  
  newproperty(:set_bgp_prepend_path, :array_matching => :all) do
    desc 'Set BGP AS path (acxtual path) prepend if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:set_bgp_med) do
    desc 'Set BGP MED if matched'
  end
  
  newproperty(:set_bgp_communities, :array_matching => :all) do
    desc 'Set BGP communities if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:append_bgp_communities, :array_matching => :all) do
    desc 'Append BGP communities if matched'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  # Not defined in winbox? 
  #   set-in-nexthop-ipv6
  #   set-in-nexthop-linklocal
  #   set-out-nexthop-ipv6
  #   set-out-nexthop-linklocal
end

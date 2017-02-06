require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_routing_filter).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter")
    filters.each do |filter|
      object = routingFilter(filter)
      if object != nil
        instances << object
      end
    end
    
    instances
  end
  
  def self.routingFilter(data)
    if data['comment'] != nil
      #Puppet.debug("Routing filter: #{data.inspect}")
      
      new(
        :ensure                 => :present,
        :name                   => data['comment'],
        :chain                  => data['chain'],
        :prefix                 => data['prefix'],
        :prefix_length          => data['prefix-length'],
        :match_chain            => data['match-chain'],
        :protocols              => data['protocol'].nil? ? nil : data['protocol'].split(','),
        :distance               => data['distance'],
        :scope                  => data['scope'],
        :target_scope           => data['target-scope'],
        :pref_src               => data['pref-src'],
        :routing_mark           => data['routing-mark'],
        :route_comment          => data['route-comment'],
        :route_tag              => data['route-tag'],
        :route_targets          => data['route-target'].nil? ? nil : data['route-target'].split(','),
        :sites_of_origin        => data['site-of-origin'].nil? ? nil : data['site-of-origin'].split(','),
        :address_families       => data['address-family'].nil? ? nil : data['address-family'].split(','),
        :ospf_type              => data['ospf-type'],
        :invert_match           => data['invert-match'],
        :bgp_as_path            => data['bgp-as-path'],
        :bgp_as_path_length     => data['bgp-as-path-length'],
        :bgp_weight             => data['bgp-weight'],
        :bgp_local_pref         => data['bgp-local-pref'],
        :bgp_med                => data['bgp-med'],
        :bgp_atomic_aggregate   => data['bgp-atomic-aggregate'],
        :bgp_origins            => data['bgp-origin'].nil? ? nil : data['bgp-origin'].split(','),
        :locally_originated_bgp => data['locally-originated-bgp'],
        :bgp_communities        => data['bgp-communities'].nil? ? nil : data['bgp-communities'].split(','),
        :action                 => data['action'],
        :jump_target            => data['jump-target'],
        :set_distance           => data['set-distance'],
        :set_scope              => data['set-scope'],
        :set_target_scope       => data['set-target-scope'],
        :set_pref_src           => data['set-pref-src'],
        :set_in_nexthops        => data['set-in-nexthop'].nil? ? nil : data['set-in-nexthop'].split(','),
        :set_in_nexthops_direct => data['set-in-nexthop-direct'].nil? ? nil : data['set-in-nexthop-direct'].split(','),
        :set_out_nexthop        => data['set-out-nexthop'],
        :set_routing_mark       => data['set-routing-mark'],
        :set_route_comment      => data['set-route-comment'],
        :set_check_gateway      => data['set-check-gateway'],
        :set_disabled           => data['set-disabled'],
        :set_type               => data['set-type'],
        :set_route_tag          => data['set-route-tag'],
        :set_use_te_nexthop     => data['set-use-te-nexthop'],
        :set_route_targets      => data['set-route-target'].nil? ? nil : data['set-route-target'].split(','),
        :append_route_targets   => data['append-route-target'].nil? ? nil : data['append-route-target'].split(','),
        :set_site_of_origin     => data['set-site-of-origin'].nil? ? nil : data['set-site-of-origin'].split(','),
        :set_bgp_weight         => data['set-bgp-weight'],
        :set_bgp_local_pref     => data['set-bgp-local-pref'],
        :set_bgp_prepend        => data['set-bgp-prepend'],
        :set_bgp_prepend_path   => data['set-bgp-prepend-path'].nil? ? nil : data['set-bgp-prepend-path'].split(','),
        :set_bgp_med            => data['set-bgp-med'],
        :set_bgp_communities    => data['set-bgp-communities'].nil? ? nil : data['set-bgp-communities'].split(','),
        :append_bgp_communities => data['append-bgp-communities'].nil? ? nil : data['append-bgp-communities'].split(',')
      )
    end
  end

  def flush
    Puppet.debug("Flushing routing filter #{resource[:name]}")

    if @property_flush[:ensure] == :present
      if resource[:chain].nil?
        raise "Chain is a required parameter."
      end
    end

    params = {}
    params["comment"] = resource[:name]
    params["chain"] = resource[:chain]    
    params["prefix"] = resource[:prefix] if !resource[:prefix].nil?
    params["prefix-length"] = resource[:prefix_length] if !resource[:prefix_length].nil?
    params["match-chain"] = resource[:match_chain] if !resource[:match_chain].nil?
    params["protocol"] = resource[:protocols].join(',') if !resource[:protocols].nil?      
    params["distance"] = resource[:distance] if !resource[:distance].nil?
    params["scope"] = resource[:scope] if !resource[:scope].nil?
    params["target-scope"] = resource[:target_scope] if !resource[:target_scope].nil?
    params["pref-src"] = resource[:pref_src] if !resource[:pref_src].nil?
    params["routing-mark"] = resource[:routing_mark] if !resource[:routing_mark].nil?
    params["route-comment"] = resource[:route_comment] if !resource[:route_comment].nil?
    params["route-tag"] = resource[:route_tag] if !resource[:route_tag].nil?
    params["route-target"] = resource[:route_targets].join(',') if !resource[:route_targets].nil?
    params["site-of-origin"] = resource[:sites_of_origin].join(',') if !resource[:sites_of_origin].nil?
    params["address-family"] = resource[:address_families].join(',') if !resource[:address_families].nil?
    params["ospf-type"] = resource[:ospf_type] if !resource[:ospf_type].nil?
    params["invert-match"] = resource[:invert_match] if !resource[:invert_match].nil?
    params["bgp-as-path"] = resource[:bgp_as_path] if !resource[:bgp_as_path].nil?
    params["bgp-as-path-length"] = resource[:bgp_as_path_length] if !resource[:bgp_as_path_length].nil?
    params["bgp-weight"] = resource[:bgp_weight] if !resource[:bgp_weight].nil?
    params["bgp-local-pref"] = resource[:bgp_local_pref] if !resource[:bgp_local_pref].nil?
    params["bgp-med"] = resource[:bgp_med] if !resource[:bgp_med].nil?
    params["bgp-atomic-aggregate"] = resource[:bgp_atomic_aggregate] if !resource[:bgp_atomic_aggregate].nil?
    params["bgp-origin"] = resource[:bgp_origins].join(',') if !resource[:bgp_origins].nil?
    params["locally-originated-bgp"] = resource[:locally_originated_bgp] if !resource[:locally_originated_bgp].nil?
    params["bgp-communities"] = resource[:bgp_communities].join(',') if !resource[:bgp_communities].nil?
    params["action"] = resource[:action] if !resource[:action].nil?
    params["jump-target"] = resource[:jump_target] if !resource[:jump_target].nil?
    params["set-distance"] = resource[:set_distance] if !resource[:set_distance].nil?
    params["set-scope"] = resource[:set_scope] if !resource[:set_scope].nil?
    params["set-target-scope"] = resource[:set_target_scope] if !resource[:set_target_scope].nil?
    params["set-pref-src"] = resource[:set_pref_src] if !resource[:set_pref_src].nil?
    params["set-in-nexthop"] = resource[:set_in_nexthops].join(',') if !resource[:set_in_nexthops].nil?
    params["set-in-nexthop-direct"] = resource[:set_in_nexthops_direct].join(',') if !resource[:set_in_nexthops_direct].nil?
    params["set-out-nexthop"] = resource[:set_out_nexthop] if !resource[:set_out_nexthop].nil?
    params["set-routing-mark"] = resource[:set_routing_mark] if !resource[:set_routing_mark].nil?
    params["set-route-comment"] = resource[:set_route_comment] if !resource[:set_route_comment].nil?
    params["set-check-gateway"] = resource[:set_check_gateway] if !resource[:set_check_gateway].nil?
    params["set-disabled"] = resource[:set_disabled] if !resource[:set_disabled].nil?
    params["set-type"] = resource[:set_type] if !resource[:set_type].nil?
    params["set-route-tag"] = resource[:set_route_tag] if !resource[:set_route_tag].nil?
    params["set-use-te-nexthop"] = resource[:set_use_te_nexthop] if !resource[:set_use_te_nexthop].nil?
    params["set-route-targets"] = resource[:set_route_targets].join(',') if !resource[:set_route_targets].nil?
    params["append-route-targets"] = resource[:append_route_targets].join(',') if !resource[:append_route_targets].nil?
    params["set-site-of-origin"] = resource[:set_site_of_origin].join(',') if !resource[:set_site_of_origin].nil?
    params["set-bgp-weight"] = resource[:set_bgp_weight] if !resource[:set_bgp_weight].nil?
    params["set-bgp-local-pref"] = resource[:set_bgp_local_pref] if !resource[:set_bgp_local_pref].nil?
    params["set-bgp-prepend"] = resource[:set_bgp_prepend] if !resource[:set_bgp_prepend].nil?
    params["set-bgp-prepend-path"] = resource[:set_bgp_prepend_path].join(',') if !resource[:set_bgp_prepend_path].nil?
    params["set-bgp-med"] = resource[:set_bgp_med] if !resource[:set_bgp_med].nil?
    params["set-bgp-communities"] = resource[:set_bgp_communities].join(',') if !resource[:set_bgp_communities].nil?
    params["append-bgp-communities"] = resource[:append_bgp_communities].join(',') if !resource[:append_bgp_communities].nil?

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/filter", params, lookup)
  end  
end

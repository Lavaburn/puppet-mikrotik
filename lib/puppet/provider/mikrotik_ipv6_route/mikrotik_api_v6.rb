require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipv6_route).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    routes = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/route")
    routes.each do |route|
      object = ipRoute(route)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.ipRoute(data)
    if data['comment'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      new(
        :ensure               => :present,
        :state                => state,
        :name                 => data['comment'],
        :dst_address          => data['dst-address'], 
        :gateway              => data['gateway'],
        :check_gateway        => data['check-gateway'],
        :type                 => data['type'],
        :distance             => data['distance'],
        :scope                => data['scope'],
        :target_scope         => data['target-scope'],
        :bgp_as_path          => data['bgp-as-path'],   
        :bgp_local_pref       => data['bgp-local-pref'],
        :bgp_prepend          => data['bgp-prepend'],
        :bgp_med              => data['bgp-med'],
        :bgp_atomic_aggregate => data['bgp-atomic-aggregate'],
        :bgp_origin           => data['bgp-origin'],
        :route_tag            => data['route-tag'],
        :bgp_communities      => data['bgp-communities']
      )
    end
  end

  def flush
    Puppet.debug("Flushing IPv6 Route #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"] = resource[:name]
    params["dst-address"] = resource[:dst_address]
    Puppet.info("IPv6 DST Address = Params: #{params["dst-address"].inspect}")
    params["gateway"] = resource[:gateway] if !resource[:gateway].nil?
    params["check-gateway"] = resource[:check_gateway] if !resource[:check_gateway].nil?
    params["type"] = resource[:type] if !resource[:type].nil?
    params["distance"] = resource[:distance] if !resource[:distance].nil?
    params["scope"] = resource[:scope] if !resource[:scope].nil?
    params["target-scope"] = resource[:target_scope] if !resource[:target_scope].nil?
    params["bgp-as-path"] = resource[:bgp_as_path] if !resource[:bgp_as_path].nil?
    params["bgp-local-pref"] = resource[:bgp_local_pref] if !resource[:bgp_local_pref].nil?
    params["bgp-prepend"] = resource[:bgp_prepend] if !resource[:bgp_prepend].nil?
    params["bgp-med"] = resource[:bgp_med] if !resource[:bgp_med].nil?
    params["bgp-atomic-aggregate"] = resource[:bgp_atomic_aggregate] if !resource[:bgp_atomic_aggregate].nil?
    params["bgp-origin"] = resource[:bgp_origin] if !resource[:bgp_origin].nil?
    params["route-tag"] = resource[:route_tag] if !resource[:route_tag].nil?
    params["bgp-communities"] = resource[:bgp_communities] if !resource[:bgp_communities].nil?

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/route", params, lookup)
  end  
end

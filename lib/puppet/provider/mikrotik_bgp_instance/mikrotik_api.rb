require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_instance).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances    
    bgp_instances = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/instance")
    instances = bgp_instances.collect { |bgp_instance| bgpInstance(bgp_instance) }    
    instances
  end
  
  def self.bgpInstance(data)        
    new(
      :ensure                      => :present,
      :name                        => data['name'],
      :as                          => data['as'],
      :router_id                   => data['router-id'],
      :redistribute_connected      => data['redistribute-connected'].to_sym,
      :redistribute_static         => data['redistribute-static'].to_sym,
      :redistribute_ospf           => data['redistribute-ospf'].to_sym,
      :redistribute_bgp            => data['redistribute-other-bgp'].to_sym,
      :out_filter                  => data['out-filter'],
      :client_to_client_reflection => data['client-to-client-reflection'].to_sym,
      :routing_table               => data['routing-table']
    )
  end

  def flush
    Puppet.info("Flushing BGP Instance #{resource[:name]}")
    
    params = {}
    params["name"] = resource[:name]
    params["as"] = resource[:as] if ! resource[:as].nil?
    params["router-id"] = resource[:router_id] if ! resource[:router_id].nil?
    params["redistribute-connected"] = resource[:redistribute_connected] if ! resource[:redistribute_connected].nil?
    params["redistribute-static"] = resource[:redistribute_static] if ! resource[:redistribute_static].nil?
    params["redistribute-ospf"] = resource[:redistribute_ospf] if ! resource[:redistribute_ospf].nil?
    params["redistribute-other-bgp"] = resource[:redistribute_bgp] if ! resource[:redistribute_bgp].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["client-to-client-reflection"] = resource[:client_to_client_reflection] if ! resource[:client_to_client_reflection].nil?
    params["routing-table"] = resource[:routing_table] if ! resource[:routing_table].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/instance", params, lookup)
  end  
end

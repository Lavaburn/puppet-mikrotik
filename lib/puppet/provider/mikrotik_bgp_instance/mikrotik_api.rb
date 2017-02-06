require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_instance).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
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
        :redistribute_connected      => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['redistribute-connected']),
        :redistribute_static         => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['redistribute-static']),
        :redistribute_ospf           => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['redistribute-ospf']),
        :redistribute_bgp            => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['redistribute-other-bgp']),
        :out_filter                  => data['out-filter'],
        :client_to_client_reflection => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['client-to-client-reflection']),
        :routing_table               => data['routing-table']
      )
  end

  def flush
    Puppet.debug("Flushing BGP Instance #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["as"] = resource[:as] if ! resource[:as].nil?
    params["router-id"] = resource[:router_id] if ! resource[:router_id].nil?
    params["redistribute-connected"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:redistribute_connected]) if ! resource[:redistribute_connected].nil?
    params["redistribute-static"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:redistribute_static]) if ! resource[:redistribute_static].nil?
    params["redistribute-ospf"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:redistribute_ospf]) if ! resource[:redistribute_ospf].nil?
    params["redistribute-other-bgp"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:redistribute_bgp]) if ! resource[:redistribute_bgp].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["client-to-client-reflection"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:client_to_client_reflection]) if ! resource[:client_to_client_reflection].nil?
    params["routing-table"] = resource[:routing_table] if ! resource[:routing_table].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/instance", params, lookup)
  end  
end

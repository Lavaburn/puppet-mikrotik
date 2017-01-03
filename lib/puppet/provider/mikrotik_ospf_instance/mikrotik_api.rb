require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ospf_instance).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_instances = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/instance")
    instances = ospf_instances.collect { |ospf_instance| ospfInstance(ospf_instance) }    
    instances
  end
  
  def self.ospfInstance(data)
      new(
        :ensure                 => :present,
        :name                   => data['name'],
        :router_id              => data['router-id'],
        :distribute_default     => data['distribute-default'],
        :redistribute_connected => data['redistribute-connected'],
        :redistribute_static    => data['redistribute-static'],
        :redistribute_ospf      => data['redistribute-other-ospf'],
        :redistribute_bgp       => data['redistribute-bgp'],
        :in_filter              => data['in-filter'],
        :out_filter             => data['out-filter'],
        :metric_default         => data['metric-default'],
        :metric_connected       => data['metric-connected'],
        :metric_static          => data['metric-static'],
        :metric_ospf            => data['metric-other-ospf'],
        :metric_bgp             => data['metric-bgp']
      )
  end

  def flush
    Puppet.debug("Flushing OSPF Instance #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["router-id"] = resource[:router_id] if ! resource[:router_id].nil?
    params["distribute-default"] = resource[:distribute_default] if ! resource[:distribute_default].nil?
    params["redistribute-connected"] = resource[:redistribute_connected] if ! resource[:redistribute_connected].nil?
    params["redistribute-static"] = resource[:redistribute_static] if ! resource[:redistribute_static].nil?
    params["redistribute-other-ospf"] = resource[:redistribute_ospf] if ! resource[:redistribute_ospf].nil?
    params["redistribute-bgp"] = resource[:redistribute_bgp] if ! resource[:redistribute_bgp].nil?
    params["in-filter"] = resource[:in_filter] if ! resource[:in_filter].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["metric-default"] = resource[:metric_default] if ! resource[:metric_default].nil?
    params["metric-connected"] = resource[:metric_connected] if ! resource[:metric_connected].nil?
    params["metric-static"] = resource[:metric_static] if ! resource[:metric_static].nil?
    params["metric-bgp"] = resource[:metric_bgp] if ! resource[:metric_bgp].nil?
    params["metric-other-ospf"] = resource[:metric_ospf] if ! resource[:metric_ospf].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/instance", params, lookup)
  end  
end

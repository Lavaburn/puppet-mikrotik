require_relative '../mikrotik_api'

# ROS 7.20+: router-id and ASN moved from template/connection to /routing/bgp/instance
Puppet::Type.type(:mikrotik_v7_bgp_instance).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7_20

  mk_resource_methods

  def self.instances
    bgp_instances = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/instance")
    instances = bgp_instances.collect { |bgp_instance| bgpInstance(bgp_instance) }
    instances
  end

  def self.bgpInstance(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure     => :present,
      :state      => state,
      :name       => data['name'],
      :as         => data['as'],
      :router_id  => data['router-id'],
      :vrf        => data['vrf'],
      :cluster_id => data['cluster-id'],
      :comment    => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing BGP Instance #{resource[:name]}")

    params = {}
    params["name"]       = resource[:name]
    params["as"]         = resource[:as] if ! resource[:as].nil?
    params["router-id"]  = resource[:router_id] if ! resource[:router_id].nil?
    params["vrf"]        = resource[:vrf] if ! resource[:vrf].nil?
    params["cluster-id"] = resource[:cluster_id] if ! resource[:cluster_id].nil?
    params["comment"]    = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/instance", params, lookup)
  end
end

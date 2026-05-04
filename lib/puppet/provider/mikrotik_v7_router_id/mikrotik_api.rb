require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_router_id).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7

  mk_resource_methods

  def self.instances
    router_ids = Puppet::Provider::Mikrotik_Api::get_all("/routing/id")
    instances = router_ids.collect { |router_id| routerId(router_id) }
    instances
  end

  def self.routerId(data)
    new(
      :ensure  => :present,
      :name    => data['name'],
      :id      => data['id'],
      :comment => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing Router ID #{resource[:name]}")

    params = {}
    params["name"]    = resource[:name]
    params["id"]      = resource[:id] if ! resource[:id].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/id", params, lookup)
  end
end

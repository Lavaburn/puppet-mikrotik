require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_routing_table).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7

  mk_resource_methods

  def self.instances
    tables = Puppet::Provider::Mikrotik_Api::get_all("/routing/table")
    instances = tables.collect { |table| routingTable(table) }
    instances
  end

  def self.routingTable(data)
    new(
      :ensure  => :present,
      :name    => data['name'],
      :fib     => data['fib'],
      :comment => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing Routing Table #{resource[:name]}")

    params = {}
    params["name"]    = resource[:name]
    params["fib"]     = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:fib]) if ! resource[:fib].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/table", params, lookup)
  end
end

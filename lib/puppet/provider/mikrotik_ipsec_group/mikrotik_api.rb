require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_group).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    groups = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/policy/group")
    instances = scripts.collect { |group| ipsecGroup(group) }
    instances
  end

  def self.ipsecGroup(data)
    new(
      :ensure   => :present,
      :name     => data['name'],
    )
  end

  def flush
    Puppet.info("Flushing Group #{resource[:name]}")

    params = { "name" => resource[:name] }
    lookup = { "name" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/policy/group", params, lookup)
  end
end

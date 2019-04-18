require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ipv6_pool).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances   
    instances = []

    pools = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/pool")
    pools.each do |pool|
      object = ipPool(pool)
      if object != nil        
        instances << object
      end
    end

    instances
  end

  def self.ipPool(data)
    new(
      :ensure        => :present,
      :name          => data['name'],
      :prefix        => data['prefix'], 
      :prefix_length => data['prefix-length']
    )
  end

  def flush
    Puppet.debug("Flushing IPv6 Pool #{resource[:name]}")

    params = {}
    params["name"] = resource[:name]
    params["prefix"] = resource[:prefix] if !resource[:prefix].nil?
    params["prefix-length"] = resource[:prefix_length] if !resource[:prefix_length].nil?

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/pool", params, lookup)
  end
end

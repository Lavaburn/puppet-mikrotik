require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_port).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/port")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure => :present,
      :state  => state,
      :name   => data['interface'],
      :bridge => data['bridge']
    )
  end

  def flush
    Puppet.debug("Flushing Bridge Port #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["interface"] = resource[:name]
    params["bridge"] = resource[:bridge]

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge/port", params, lookup)
  end  
end
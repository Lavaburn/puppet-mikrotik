require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ospf_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_interfaces = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/interface")
    instances = ospf_interfaces.collect { |ospf_interface| ospfInterface(ospf_interface) }    
    instances
  end

  def self.ospfInterface(data)
      new(
        :ensure   => :present,
        :name     => data['interface'],
        :cost     => data['cost'],
        :priority => data['priority']
      )
  end

  def flush
    Puppet.debug("Flushing OSPF Interface #{resource[:name]}")
      
    params = {}
    params["interface"] = resource[:name]
    params["cost"] = resource[:cost] if ! resource[:cost].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/interface", params, lookup)
  end  
end

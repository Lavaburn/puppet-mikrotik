require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ospf_network).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_networks = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/network")
    instances = ospf_networks.collect { |ospf_network| ospfNetwork(ospf_network) }    
    instances
  end
  
  def self.ospfNetwork(data)
      new(
        :ensure  => :present,
        :name    => data['network'],
        :area    => data['area'],
        :comment => data['comment'],
      )
  end

  def flush
    Puppet.debug("Flushing OSPF Network #{resource[:name]}")
      
    params = {}
    params["network"] = resource[:name]
    params["area"] = resource[:area] if ! resource[:area].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["network"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/network", params, lookup)
  end  
end

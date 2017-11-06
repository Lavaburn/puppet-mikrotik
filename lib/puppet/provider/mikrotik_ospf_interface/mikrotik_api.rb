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
        :ensure                 => :present,
        :name                   => data['interface'],
        :cost                   => data['cost'],
        :priority               => data['priority'],
        :authentication         => data['authentication'],
        :authentication_key     => data['authentication-key'],          
        :authentication_key_id  => data['authentication-key-id'],
        :network_type           => data['network-type'],
        :passive                => data['passive'],
        :use_bfd                => data['use-bfd']
      )
  end

  def flush
    Puppet.debug("Flushing OSPF Interface #{resource[:name]}")
      
    params = {}
    params["interface"] = resource[:name]
    params["cost"] = resource[:cost] if ! resource[:cost].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["authentication"] = resource[:authentication] if ! resource[:authentication].nil?
    params["authentication-key"] = resource[:authentication_key] if ! resource[:authentication_key].nil?
    params["authentication-key-id"] = resource[:authentication_key_id] if ! resource[:authentication_key_id].nil?
    params["network-type"] = resource[:network_type] if ! resource[:network_type].nil?
    params["passive"] = resource[:passive] if ! resource[:passive].nil?
    params["use-bfd"] = resource[:use_bfd] if ! resource[:use_bfd].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/interface", params, lookup)
  end  
end

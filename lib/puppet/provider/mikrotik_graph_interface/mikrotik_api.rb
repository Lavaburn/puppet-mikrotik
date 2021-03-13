require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_graph_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/tool/graphing/interface")
    instances = interfaces.collect { |interface| toolGraphInterface(interface) }    
    instances
  end
  
  def self.toolGraphInterface(data)
      new(
        :ensure        => :present,
        :name          => data['interface'],
        :allow         => data['allow-address'],
        :store_on_disk => data['store-on-disk']
      )
  end

  def flush
    Puppet.debug("Flushing Tool Graph Interface #{resource[:name]}")
      
    params = {}
    params["interface"] = resource[:name]
    params["allow-address"] = resource[:allow] if ! resource[:allow].nil?
    params["store-on-disk"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:store_on_disk]) if ! resource[:store_on_disk].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/tool/graphing/interface", params, lookup)
  end  
end
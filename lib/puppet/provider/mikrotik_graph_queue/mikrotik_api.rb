require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_graph_queue).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/tool/graphing/queue")
    instances = interfaces.collect { |interface| toolGraphQueue(interface) }    
    instances
  end
  
  def self.toolGraphQueue(data)
      new(
        :ensure        => :present,
        :name          => data['simple-queue'],
        :allow         => data['allow-address'],
        :store_on_disk => data['store-on-disk'],
        :allow_target  => data['allow-target']
      )
  end

  def flush
    Puppet.debug("Flushing Tool Graph Queue #{resource[:name]}")
      
    params = {}
    params["simple-queue"] = resource[:name]
    params["allow-address"] = resource[:allow] if ! resource[:allow].nil?
    params["store-on-disk"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:store_on_disk]) if ! resource[:store_on_disk].nil?
    params["allow-target"] = resource[:allow_target] if ! resource[:allow_target].nil?

    lookup = {}
    lookup["simple-queue"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/tool/graphing/queue", params, lookup)
  end  
end

require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_graph_resource).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    resources = Puppet::Provider::Mikrotik_Api::get_all("/tool/graphing/resource")
    instances = resources.collect { |resource| toolGraphResource(resource) }    
    instances
  end
  
  def self.toolGraphResource(data)
      new(
        :ensure        => :present,
        :name          => 'resource',
        :allow         => data['allow-address'],
        :store_on_disk => data['store-on-disk']
      )
  end

  def flush
    Puppet.debug("Flushing Tool Graph Resource #{resource[:name]}")
      
    params = {}
    params["allow-address"] = resource[:allow] if ! resource[:allow].nil?
    params["store-on-disk"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:store_on_disk]) if ! resource[:store_on_disk].nil?

    lookup = {}
    lookup["allow-address"] = @original_values[:allow]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/tool/graphing/resource", params, lookup)
  end  
end

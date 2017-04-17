require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_pool).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    pools = Puppet::Provider::Mikrotik_Api::get_all("/ip/pool")
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
      :ensure    => :present,
      :name      => data['name'],
      :ranges    => data['ranges'].split(','), 
      :next_pool => data['next-pool']
    )
  end

  def flush
    Puppet.debug("Flushing IP Pool #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["ranges"] = resource[:ranges].join(',') if !resource[:ranges].nil?
    params["next-pool"] = resource[:next_pool] if !resource[:next_pool].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/pool", params, lookup)
  end  
end

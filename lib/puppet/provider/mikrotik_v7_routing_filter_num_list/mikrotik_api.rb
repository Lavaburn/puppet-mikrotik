require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_routing_filter_num_list).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/num-list")
    filters.each do |filter|
      object = routingFilter(filter, filters)
      if object != nil
        instances << object
      end
    end
    
    instances
  end

  def self.routingFilter(data, all_filters)
    if data['comment'] != nil
      #Puppet.debug("Routing filter: #{data.inspect}")

      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      new(
        :ensure => :present,
        :state  => state,
        :name   => data['comment'],
        :list   => data['list'],
        :range  => data['range']
      )
    end
  end

  def flush
    Puppet.debug("Flushing routing filter num list #{resource[:name]}")

    unless @property_flush[:ensure] == :absent
      if resource[:list].nil?
        raise "List is a required parameter."
      end
    end

    params = {}      

    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end
          
    params["comment"] = resource[:name]
    params["list"] = resource[:list] if !resource[:list].nil?
    params["range"] = resource[:range] if !resource[:range].nil?

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    
    simple_flush("/routing/filter/num-list", params, lookup)        
  end
end

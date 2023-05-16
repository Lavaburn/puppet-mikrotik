require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_routing_filter_community_list).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/community-list")
    filters.each do |filter|
      object = routingFilter(filter, filters, :normal)
      if object != nil
        instances << object
      end
    end
    
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/community-ext-list")
    filters.each do |filter|
      object = routingFilter(filter, filters, :extended)
      if object != nil
        instances << object
      end
    end
    
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/community-large-list")
    filters.each do |filter|
      object = routingFilter(filter, filters, :large)
      if object != nil
        instances << object
      end
    end
    
    instances
  end

  def self.routingFilter(data, all_filters, type)
    if data['comment'] != nil
      #Puppet.debug("#{type} Routing filter: #{data.inspect}")
  
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      communities = []
      if !data['communities'].nil?
        communities = data['communities'].split(',')
      end
  
      new(
        :ensure      => :present,
        :state       => state,
        :type        => type,
        :name        => data['comment'],
        :list        => data['list'],
        :communities => communities,
        :regexp      => data['regexp']
      )
    end
  end

  def flush
    Puppet.debug("Flushing routing filter community list #{resource[:name]}")

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
    params["list"] = resource[:list]
    params["communities"] = resource[:communities].join(',') if !resource[:communities].nil?
    params["regexp"] = resource[:regexp] if !resource[:regexp].nil?
      
    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    
    if resource[:type] == :normal
      simple_flush("/routing/filter/community-list", params, lookup)        
    end    
    if resource[:type] == :extended
      simple_flush("/routing/filter/community-ext-list", params, lookup)        
    end    
    if resource[:type] == :large
      simple_flush("/routing/filter/community-large-list", params, lookup)        
    end
  end
end

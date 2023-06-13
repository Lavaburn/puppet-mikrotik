require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_routing_filter_rule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/rule")
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

      chain_order = getChainOrder(data['.id'], data['chain'], all_filters)
      
      new(
        :ensure      => :present,
        :state       => state,
        :name        => data['comment'],
        :chain       => data['chain'],
        :chain_order => chain_order.to_s,
        :rule        => data['rule']            # BUGFIX: ONLY RETRIEVES 1 LINE (\r\n) !!!
      )
    end
  end

  def flush
    Puppet.debug("Flushing routing filter rule #{resource[:name]}")

    unless @property_flush[:ensure] == :absent
      if resource[:chain].nil?
        raise "Chain is a required parameter."
      end
    end

    params = {}      

    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end
    
    if !resource[:chain_order].nil?
      all_filters = Puppet::Provider::Mikrotik_Api::get_all("/routing/filter/rule")
      ids = self.class.getChainIds(resource[:chain], all_filters)
      
      if @property_flush[:ensure] == :present
        unless resource[:chain_order] > ids.length          
          filter_id_after = ids[resource[:chain_order].to_i - 1]# index starts at 0, order starts at 1
          params["place-before"] = filter_id_after
        end
      end
    end
      
    params["comment"] = resource[:name]
    params["chain"] = resource[:chain]    
    params["rule"] = resource[:rule]

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    
    simple_flush("/routing/filter/rule", params, lookup)
        
    if !resource[:chain_order].nil?
      if @property_flush.empty?
        id_list = Puppet::Provider::Mikrotik_Api::lookup_id("/routing/filter/rule", lookup)
        id_list.each do |id|
          chain_order = self.class.getChainOrder(id, resource[:chain], all_filters)
          if resource[:chain_order].to_i != chain_order
            self.class.moveFilter(id, resource[:chain], chain_order, resource[:chain_order].to_i, all_filters)
          end
        end
      end
    end
  end
    
  def self.getChainOrder(lookup_id, lookup_chain, all_filters)    
    ids = getChainIds(lookup_chain, all_filters)
    
    chain_order = 1
    ids.each do |id|
      if id == lookup_id
         return chain_order
      end        
     
      chain_order = chain_order + 1
    end
  end
  
  def self.getChainIds(lookup_chain, all_filters)
    ids = all_filters.collect do |filter|
      if filter['chain'] == lookup_chain
         filter['.id']
      end
    end
    
    ids.compact
  end
    
  def self.moveFilter(filter_id, lookup_chain, old_chain_order, new_chain_order, all_filters)
    Puppet.debug("Moving filter #{filter_id} from position #{old_chain_order} to position #{new_chain_order} in chain #{lookup_chain}.")
    
    if new_chain_order == old_chain_order
      return
    end

    if new_chain_order > old_chain_order
      lookup_order = new_chain_order + 1
    else
      lookup_order = new_chain_order
    end

    destination = nil
    chain_pos = 0

    all_filters.each do |filter|
      if filter['chain'] == lookup_chain
        chain_pos = chain_pos + 1         
      end
      
      if chain_pos == new_chain_order
        destination = filter['.id']  
      end
      
      if chain_pos == lookup_order
        destination = filter['.id']   
        break
      end
    end

    if filter_id == destination
      return
    end

    move_params = {}
    move_params["numbers"] = filter_id
    move_params["destination"] = destination if destination != nil
    result = Puppet::Provider::Mikrotik_Api::move("/routing/filter/rule", move_params)
  end
end

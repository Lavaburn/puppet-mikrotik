require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_route_rule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    rules = Puppet::Provider::Mikrotik_Api::get_all("/ip/route/rule")
    rules.each do |rule|
      object = ipRule(rule)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.ipRule(data)
    if data['comment'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      new(
        :ensure       => :present,
        :state        => state,
        :name         => data['comment'],
        :src_address  => data['src-address'],
        :dst_address  => data['dst-address'],
        :routing_mark => data['routing-mark'],
        :interface    => data['interface'],
        :action       => data['action'],
        :table        => data['table']
      )
    end
  end

  def flush
    Puppet.debug("Flushing IP Route Rule #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"] = resource[:name]
    params["src-address"] = resource[:src_address] if !resource[:src_address].nil?
    params["dst-address"] = resource[:dst_address] if !resource[:dst_address].nil?
    params["routing-mark"] = resource[:routing_mark] if !resource[:routing_mark].nil?
    params["interface"] = resource[:interface] if !resource[:interface].nil?
    params["action"] = resource[:action] if !resource[:action].nil?
    params["table"] = resource[:table] if !resource[:table].nil?

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/route/rule", params, lookup)
  end  
end

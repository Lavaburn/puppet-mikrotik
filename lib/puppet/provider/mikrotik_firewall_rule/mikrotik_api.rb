require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_firewall_rule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    filter_rules = get_all("/ip/firewall/filter")
    filter_rules.each do |rule|
      object = firewallRule(rule, 'filter')
      if object != nil
        instances << object
      end
    end
    
    nat_rules = get_all("/ip/firewall/nat")
    nat_rules.each do |rule|
      object = firewallRule(rule, 'nat')
      if object != nil
        instances << object
      end
    end
    
    mangle_rules = get_all("/ip/firewall/mangle")
    mangle_rules.each do |rule|
      object = firewallRule(rule, 'mangle')
      if object != nil
        instances << object
      end      
    end
    
    # TODO - sort per chain and inject sequence?

    instances
  end
  
  def self.firewallRule(rule, table)
    if rule['comment'] != nil
      new(
        :ensure      => :present,
        :name        => rule['comment'],
        :table       => table,
        :chain       => rule['chain'],
        :src_address => rule['src-address'],
        :action      => rule['action']
        # TODO
        #:sequence    => 0
      )
    end
  end

  def flush
    Puppet.debug("Flushing Firewall Rule #{resource[:name]}")
    
    if @property_flush[:ensure] == :present
      if resource[:table].nil? or resource[:chain].nil?
        raise "Table and Chain are required parameters."
      end      
    end
    
    # TODO - automate... below does not work...
#    params = @property_hash.reject { |k, _v| !resource[k] }
#    params.delete_if {|k,v| [:ensure, :name, :src_address].include? k }
    
    params = {}
    params["comment"] = resource[:name]
    params["chain"] = resource[:chain] if ! resource[:chain].nil?   
    params["src-address"] = resource[:src_address] if ! resource[:src_address].nil?   
    params["action"] = resource[:action] if ! resource[:action].nil?   
    
    lookup = { "comment" => resource[:name] }
    
    #Puppet.debug("Rule: #{params.inspect} - Lookup: #{lookup.inspect}")
  
    if @property_hash.empty?  
      table = resource[:table]
    else
      table = @property_hash[:table]
    end
            
    simple_flush("/ip/firewall/#{table}", params, lookup)
  end
end
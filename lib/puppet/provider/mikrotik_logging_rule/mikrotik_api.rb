require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_logging_rule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    rules = get_all("/system/logging")
    instances = rules.collect { |rule| loggingRule(rule) }
  end
  
  def self.loggingRule(rule)
    topics = rule['topics'].split(',')
    name = topics.join('_') + "_" + rule['action']
    
    new(
      :ensure => :present,
      :name   => name,
      :topics => topics,
      :action => rule['action']
    )
  end

  def flush
    Puppet.debug("Flushing Logging Rule #{resource[:name]}")
    
    if resource[:topics].nil? or resource[:action].nil?
      raise "topics and action are required parameters."
    end      
    
    params = {}
    params["topics"] = resource[:topics].join(',')
    params["action"] = resource[:action] 
    
    lookup = { 
      "topics" => resource[:topics].join(','),
      "action" => resource[:action]
    }
    
    Puppet.debug("Rule: #{params.inspect} - Lookup: #{lookup.inspect}")
      
    simple_flush("/system/logging", params, lookup)
  end
end

require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_msti_port).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    ports = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/port/mst-override")
    instances = ports.collect { |port| override(port) unless port['dynamic'] == "yes" }    
    instances
  end
  
  def self.override(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    if data['comment'].nil?
      name = data['interface'] + " on " + data['identifier']
    else
      name = data['comment']
    end
        
    new(
      :ensure             => :present,
      :state              => state,
      :name               => name,
      :interface          => data['interface'],
      :identifier         => data['identifier'],
      :priority           => data['priority'],
      :internal_path_cost => data['internal-path-cost']
    )
  end

  def flush
    Puppet.debug("Flushing Bridge Port MST Override #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"]             = resource[:name]
    params["interface"]           = resource[:interface]      
    params["identifier"]          = resource[:identifier]
    params["priority"]            = resource[:priority] if ! resource[:priority].nil?
    params["internal-path-cost"]  = resource[:internal_path_cost] if ! resource[:internal_path_cost].nil?

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge/port/mst-override", params, lookup)
  end  
end

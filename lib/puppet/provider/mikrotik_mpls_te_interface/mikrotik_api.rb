require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_mpls_te_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/mpls/traffic-eng/interface")
    instances = interfaces.collect { |interface| teInterface(interface) }    
    instances
  end

  def self.teInterface(data)    
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :name      => data['interface'],
      :ensure    => :present,
      :state     => state,
      :bandwidth => data['bandwidth']
    )
  end

  def flush 
    Puppet.debug("Flushing MPLS TE Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["interface"] = resource[:name]
    params["bandwidth"] = resource[:bandwidth] if ! resource[:bandwidth].nil?
      
    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/mpls/traffic-eng/interface", params, lookup)
  end
end
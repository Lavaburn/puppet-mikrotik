require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_romon_port).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/tool/romon/port")
    networks = interfaces.collect { |interface| romonPort(interface) }
    networks
  end
  
  def self.romonPort(data)     
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end   
    
    new(
      :ensure   => :present,
      :state    => state,
      :name     => data['interface'],
      :forbid   => data['forbid'],# TODO
      :secrets  => data['secrets'].split(','),
      :cost     => data['cost']
    )
  end

  def flush
    Puppet.info("Flushing RoMON Port #{resource[:name]}")
    
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["interface"] = resource[:name]
    params["forbid"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:forbid]) if ! resource[:forbid].nil?
    params["secrets"] = resource[:secrets].join(',') if ! resource[:secrets].nil?
    params["cost"] = resource[:cost]

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/tool/romon/port", params, lookup)
  end  
end

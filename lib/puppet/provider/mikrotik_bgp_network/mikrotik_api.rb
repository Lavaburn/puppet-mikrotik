require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_network).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances    
    bgp_networks = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/network")
    networks = bgp_networks.collect { |bgp_network| bgpNetwork(bgp_network) }    
    networks
  end
  
  def self.bgpNetwork(data)     
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end   
    
    new(
      :ensure      => :present,
      :state       => state,
      :name        => data['network'],
      :synchronize => data['synchronize']
    )
  end

  def flush
    Puppet.info("Flushing BGP Network #{resource[:name]}")
    
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["network"] = resource[:name]
    params["synchronize"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:synchronize]) if ! resource[:synchronize].nil?

    lookup = {}
    lookup["network"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/network", params, lookup)
  end  
end

require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_address).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances    
    addresses = Puppet::Provider::Mikrotik_Api::get_all("/ip/address")
    instances = addresses.collect { |address| ipAddress(address) }    
    instances
  end
  
  def self.ipAddress(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure     => :present,
      :state      => state,
      :name       => data['address'],
      :interface  => data['interface']
    )
  end

  def flush
    Puppet.debug("Flushing IP Address #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["address"]   = resource[:name]
    params["interface"] = resource[:interface]

    lookup = {}
    lookup["address"] = resource[:address]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/address", params, lookup)
  end  
end

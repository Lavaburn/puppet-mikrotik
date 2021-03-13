require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipv6_address).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    addresses = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/address")
    instances = addresses.collect { |address| ipAddress(address) }    
    instances
  end
  
  def self.ipAddress(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    if data['eui-64']
      address = data['address']
      # TODO: remove last 4 octets
    else
      address = data['address']
    end   
    
    new(
      :ensure    => :present,
      :state     => state,
      :name      => address,
      :interface => data['interface'],
      :advertise => data['advertise'],
      :eui64     => data['eui-64'],
      :from_pool => data['from-pool']
    )
  end

  def flush
    Puppet.debug("Flushing IPv6 Address #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["address"]   = resource[:name]
    params["interface"] = resource[:interface]
    params["advertise"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:advertise]) if ! resource[:advertise].nil?
    params["eui-64"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:eui64]) if ! resource[:eui64].nil?
    params["from-pool"] = resource[:from_pool] if ! resource[:from_pool].nil?

    lookup = {}
    lookup["address"] = resource[:address]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/address", params, lookup)
  end  
end

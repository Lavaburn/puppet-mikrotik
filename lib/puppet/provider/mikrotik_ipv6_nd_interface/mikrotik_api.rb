require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipv6_nd_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/nd")
    instances = interfaces.collect { |interface| ndInterface(interface) }    
    instances
  end
  
  def self.ndInterface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure                 => :present,
      :state                  => state,
      :name                   => data['interface'],
      :ra_interval            => data['ra-interval'],
      :ra_delay               => data['ra-delay'],
      :mtu                    => data['mtu'],
      :reachable_time         => data['reachable-time'],
      :retransmit_interval    => data['retransmit-interval'],
      :ra_lifetime            => data['ra-lifetime'],
      :hop_limit              => data['hop-limit'],
      :advertise_mac          => data['advertise-mac-address'],         # BOOLEAN
      :advertise_dns          => data['advertise-dns'],                 # BOOLEAN
      :managed_address_config => data['managed-address-configuration'], # BOOLEAN
      :other_config           => data['other-configuration']            # BOOLEAN
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
    
    params["interface"]   = resource[:name]
    params["ra-interval"] = resource[:ra_interval] if ! resource[:ra_interval].nil?
    params["ra-delay"] = resource[:ra_delay] if ! resource[:ra_delay].nil?
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["reachable-time"] = resource[:reachable_time] if ! resource[:reachable_time].nil?
    params["retransmit-interval"] = resource[:retransmit_interval] if ! resource[:retransmit_interval].nil?
    params["ra-lifetime"] = resource[:ra_lifetime] if ! resource[:ra_lifetime].nil?
    params["hop-limit"] = resource[:hop_limit] if ! resource[:hop_limit].nil?
    params["advertise-mac-address"] = resource[:advertise_mac] if ! resource[:advertise_mac].nil?
    params["advertise-dns"] = resource[:advertise_dns] if ! resource[:advertise_dns].nil?
    params["managed-address-configuration"] = resource[:managed_address_config] if ! resource[:managed_address_config].nil?
    params["other-configuration"] = resource[:other_config] if ! resource[:other_config].nil?
    #    params["xxx-xxx"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:xxx_xxx]) if ! resource[:xxx_xxx].nil?
      
    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/nd", params, lookup)
  end  
end

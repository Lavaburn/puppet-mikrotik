require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_dhcp_server).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    servers = Puppet::Provider::Mikrotik_Api::get_all("/ip/dhcp-server")
    servers.each do |server|
      object = dhcpServer(server)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.dhcpServer(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
        
    new(
      :ensure           => :present,
      :state            => state,
      :name             => data['name'],
      :interface        => data['interface'],
      :relay            => data['relay'],
      :lease_time       => data['lease-time'],
      :bootp_lease_time => data['bootp-lease-time'],
      :address_pool     => data['address-pool'],
      :src_address      => data['src-address'],
      :delay_threshold  => data['delay-threshold'],
      :authoritative    => data['authoritative'],
      :bootp_support    => data['bootp-support'],
      :lease_script     => data['lease-script'],
      :add_arp          => (data['add-arp'].nil? ? :false : data['add-arp']),
      :always_broadcast => (data['always-broadcast'].nil? ? :false : data['always-broadcast']),
      # Required for newer versions of v6 (>=v6.45 ??)
      :use_radius       => Puppet::Provider::Mikrotik_Api::convertYesNoToBool(data['use-radius']).to_s
    )
  end

  def flush
    Puppet.debug("Flushing DHCP Server #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["interface"] = resource[:interface] if !resource[:interface].nil?
    params["relay"] = resource[:relay] if !resource[:relay].nil?
    params["lease-time"] = resource[:lease_time] if !resource[:lease_time].nil?
    params["bootp-lease-time"] = resource[:bootp_lease_time] if !resource[:bootp_lease_time].nil?
    params["address-pool"] = resource[:address_pool] if !resource[:address_pool].nil?
    params["src-address"] = resource[:src_address] if !resource[:src_address].nil?
    params["delay-threshold"] = resource[:delay_threshold] if !resource[:delay_threshold].nil?
    params["authoritative"] = resource[:authoritative] if !resource[:authoritative].nil?
    params["bootp-support"] = resource[:bootp_support] if !resource[:bootp_support].nil?
    params["lease-script"] = resource[:lease_script] if !resource[:lease_script].nil?
      
    params["add-arp"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:add_arp]) if ! resource[:add_arp].nil?
    params["always-broadcast"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:always_broadcast]) if ! resource[:always_broadcast].nil?
    params["use-radius"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:use_radius]) if ! resource[:use_radius].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/dhcp-server", params, lookup)
  end  
end

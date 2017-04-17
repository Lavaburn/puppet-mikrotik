require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_eoip).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/eoip")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure          => :present,
      :state           => state,
      :name            => data['name'],
      :mtu             => data['mtu'],
      :admin_mac       => data['admin-mac'],
      :arp             => data['arp'],
      :arp_timeout     => data['arp-timeout'],
      :local_address   => data['local-address'],
      :remote_address  => data['remote-address'],
      :tunnel_id       => data['tunnel-id'],
      :ipsec_secret    => data['ipsec-secret'],
      :keepalive       => data['keepalive'],
      :dscp            => data['dscp'],
      :dont_fragment   => data['dont-fragment'],
      :clamp_tcp_mss   => data['clamp-tcp-mss'],
      :allow_fast_path => data['allow-fast-path']
    )
  end

  def flush
    Puppet.debug("Flushing EoIP Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["admin-mac"] = resource[:admin_mac] if ! resource[:admin_mac].nil?
    params["arp"] = resource[:arp] if ! resource[:arp].nil?
    params["arp-timeout"] = resource[:arp_timeout] if ! resource[:arp_timeout].nil?
    params["local-address"] = resource[:local_address] if ! resource[:local_address].nil?
    params["remote-address"] = resource[:remote_address] if ! resource[:remote_address].nil?
    params["tunnel-id"] = resource[:tunnel_id] if ! resource[:tunnel_id].nil?      
    params["ipsec-secret"] = resource[:ipsec_secret] if ! resource[:ipsec_secret].nil?
    params["keepalive"] = resource[:keepalive] if ! resource[:keepalive].nil?
    params["dscp"] = resource[:dscp] if ! resource[:dscp].nil?
    params["dont-fragment"] = resource[:dont_fragment] if ! resource[:dont_fragment].nil?
    params["clamp-tcp-mss"] = resource[:clamp_tcp_mss] if ! resource[:clamp_tcp_mss].nil?
    params["allow-fast-path"] = resource[:allow_fast_path] if ! resource[:allow_fast_path].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/eoip", params, lookup)
  end  
end
require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_gre).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/gre")
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
      :local_address   => data['local-address'],
      :remote_address  => data['remote-address'],
      :ipsec_secret    => data['ipsec-secret'],
      :keepalive       => data['keepalive'],
      :dscp            => data['dscp'],
      :dont_fragment   => data['dont-fragment'],
      :clamp_tcp_mss   => data['clamp-tcp-mss'],
      :allow_fast_path => data['allow-fast-path']
    )
  end

  def flush
    Puppet.debug("Flushing GRE Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["local-address"] = resource[:local_address] if ! resource[:local_address].nil?
    params["remote-address"] = resource[:remote_address] if ! resource[:remote_address].nil?
    params["ipsec-secret"] = resource[:ipsec_secret] if ! resource[:ipsec_secret].nil?
    params["keepalive"] = resource[:keepalive] if ! resource[:keepalive].nil?
    params["dscp"] = resource[:dscp] if ! resource[:dscp].nil?
    params["dont-fragment"] = resource[:dont_fragment] if ! resource[:dont_fragment].nil?
    params["clamp-tcp-mss"] = resource[:clamp_tcp_mss] if ! resource[:clamp_tcp_mss].nil?
    params["allow-fast-path"] = resource[:allow_fast_path] if ! resource[:allow_fast_path].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/gre", params, lookup)
  end  
end
require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_hotspot).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    servers = Puppet::Provider::Mikrotik_Api::get_all("/ip/hotspot")
    servers.each do |server|
      object = hsServer(server)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end

  def self.hsServer(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
        
    new(
      :ensure            => :present,
      :state             => state,
      :name              => data['name'],
      :address_pool      => data['address-pool'],
      :addresses_per_mac => data['addresses-per-mac'],
      :idle_timeout      => data['idle-timeout'],
      :interface         => data['interface'],
      :keepalive_timeout => data['keepalive-timeout'],
      :login_timeout     => data['login-timeout'],
      :profile           => data['profile']
    )
  end

  def flush
    Puppet.debug("Flushing Hotspot Server #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["address-pool"] = resource[:address_pool] if !resource[:address_pool].nil?
    params["addresses-per-mac"] = resource[:addresses_per_mac] if !resource[:addresses_per_mac].nil?
    params["idle-timeout"] = resource[:idle_timeout] if !resource[:idle_timeout].nil?
    params["interface"] = resource[:interface] if !resource[:interface].nil?
    params["keepalive-timeout"] = resource[:keepalive_timeout] if !resource[:keepalive_timeout].nil?
    params["login-timeout"] = resource[:login_timeout] if !resource[:login_timeout].nil?
    params["profile"] = resource[:profile] if !resource[:profile].nil?
      
    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/hotspot", params, lookup)
  end  
end

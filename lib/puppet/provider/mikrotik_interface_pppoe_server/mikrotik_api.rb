require_relative '../mikrotik_api'
Puppet::Type.type(:mikrotik_interface_pppoe_server).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  mk_resource_methods
  def self.instances    
    instances = []
    servers = Puppet::Provider::Mikrotik_Api::get_all("/interface/pppoe-server/server")
    servers.each { |server|
      instances << pppoeServer(server)
    }
    instances
  end

  def self.pppoeServer(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure               => :present,
      :state                => state,
      :name                 => data['service-name'],
      :interface            => data['interface'],
      :max_mtu              => data['max-mtu'],
      :max_mru              => data['max-mru'],
      :mrru                 => data['mrru'],
      :authentication       => data['authentication'].split(','),
      :keepalive            => data['keepalive-timeout'],
      :one_session_per_host => data['one-session-per-host'],
      :max_sessions         => data['max-sessions'],
      :pado_delay           => data['pado-delay'],
      :default_profile      => data['default-profile']
    )
  end

  def flush
    Puppet.debug("Flushing PPPoE Server #{resource[:name]}")
    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["service-name"] = resource[:name]
    params["interface"] = resource[:interface]
      
    params["max-mtu"] = resource[:max_mtu] if !resource[:max_mtu].nil?
    params["max-mru"] = resource[:max_mru] if !resource[:max_mru].nil?
    params["mrru"] = resource[:mrru] if !resource[:mrru].nil?

    params["authentication"] = resource[:authentication].join(',') if !resource[:authentication].nil?
      
    params["keepalive-timeout"] = resource[:keepalive] if !resource[:keepalive].nil?
    params["one-session-per-host"] = resource[:one_session_per_host] if !resource[:one_session_per_host].nil?
    params["max-sessions"] = resource[:max_sessions] if !resource[:max_sessions].nil?
    params["pado-delay"] = resource[:pado_delay] if !resource[:pado_delay].nil?
    params["default-profile"] = resource[:default_profile] if !resource[:default_profile].nil?

    lookup = {"service-name" => resource[:name]}
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    simple_flush("/interface/pppoe-server/server", params, lookup)
  end  
end

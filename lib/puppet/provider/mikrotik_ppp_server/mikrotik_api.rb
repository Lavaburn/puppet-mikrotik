require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ppp_server).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik

  mk_resource_methods

  def self.instances    
    instances = []

    pptp = Puppet::Provider::Mikrotik_Api::get_all("/interface/pptp-server/server")
    pptp.each { |server| 
      instances << pppServer('pptp', server)
    }

    l2tp = Puppet::Provider::Mikrotik_Api::get_all("/interface/l2tp-server/server")
    l2tp.each { |server|
      instances << pppServer('l2tp', server)
    }

    instances
  end

  def self.pppServer(type, data)
    if data['enabled'] == 'true'
      state = :enabled
    else
      state = :disabled
    end

    authentication = data['authentication'].nil? ? nil : data['authentication'].split(',')
    
    new(
      :ensure            => :present,
      :name              => type,
      :state             => state,
      :max_mtu           => data['max-mtu'],
      :max_mru           => data['max-mru'],          
      :mrru              => data['mrru'],
      :authentication    => authentication,
      :keepalive_timeout => data['keepalive-timeout'],
      :default_profile   => data['default-profile'],
      :max_sessions      => data['max-sessions'],
      :use_ipsec         => data['use-ipsec'],
      :ipsec_secret      => data['ipsec-secret'],
      :allow_fastpath    => data['allow-fastpath']  
    )
  end

  def flush
    Puppet.debug("Flushing PPP Server #{resource[:name]}")
    
    if (@property_hash[:name] != 'pptp' && @property_hash[:name] != 'l2tp') 
      raise "PPP server should be of type PPTP or L2TP"
    end
      
    params = {}
    
    if @property_hash[:state] == :disabled
      params["enabled"] = false
    elsif @property_hash[:state] == :enabled
      params["enabled"] = true
    end
      
    params["max-mtu"] = resource[:max_mtu] if ! resource[:max_mtu].nil?
    params["max-mru"] = resource[:max_mru] if ! resource[:max_mru].nil?
    params["mrru"] = resource[:mrru] if ! resource[:mrru].nil?
    params["authentication"] = resource[:authentication].join(',') if ! resource[:authentication].nil?      
    params["keepalive-timeout"] = resource[:keepalive_timeout] if ! resource[:keepalive_timeout].nil?
    params["default-profile"] = resource[:default_profile] if ! resource[:default_profile].nil?
    params["max-sessions"] = resource[:max_sessions] if ! resource[:max_sessions].nil?
    params["use-ipsec"] = resource[:use_ipsec] if ! resource[:use_ipsec].nil?
    params["ipsec-secret"] = resource[:ipsec_secret] if ! resource[:ipsec_secret].nil?
    params["allow-fastpath"] = resource[:allow_fastpath] if ! resource[:allow_fastpath].nil?
    
    Puppet.debug("PPP Server: #{resource[:name]} - Params: #{params.inspect}")

    if (@property_hash[:name] == 'pptp') 
      result = Puppet::Provider::Mikrotik_Api::set("/interface/pptp-server/server", params)
    end
    if (@property_hash[:name] == 'l2tp') 
      result = Puppet::Provider::Mikrotik_Api::set("/interface/l2tp-server/server", params)
    end
  end  
end

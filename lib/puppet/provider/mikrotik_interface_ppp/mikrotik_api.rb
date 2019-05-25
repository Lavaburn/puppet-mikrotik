require 'puppet/provider/mikrotik_api'
Puppet::Type.type(:mikrotik_interface_ppp).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  mk_resource_methods
  def self.instances    
    instances = []
    ovpn = Puppet::Provider::Mikrotik_Api::get_all("/interface/ovpn-client")
    ovpn.each { |client|
      instances << pppClient('ovpn_client', client)
    }
    instances
  end

  def self.pppClient(type,data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    authentication = data['authentication'] || data['auth'] 
    cert = data['certificate'] == 'none' ? nil : data['certificate']

    new(
      :ensure            => :present,
      :state             => state,
      :name              => data['name'],
      :ppp_type          => type,
      :max_mtu           => data['max-mtu'],
      :mac_address       => data['mac-address'],
      :connect_to        => data['connect-to'],
      :port              => data['port'],
      :mode              => data['mode'],
      :user              => data['user'],
      :password          => data['password'],
      :profile           => data['profile'],
      :certificate       => cert,
      :add_default_route => data['add_default_route'],
      :authentication    => authentication,
      :cipher            => data['cipher']
    )
  end


  def flush
    Puppet.debug("Flushing PPP Client #{resource[:name]}")
    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    attributes = %i{name max_mtu mac_address connect_to port mode user password profile certificate cipher add_default_route}
    attributes.each do |attrib|
      param_name = attrib.to_s.tr('_','-')
      params[param_name] = resource[attrib] unless resource[attrib].nil?  
    end

    auth_key = resource[:ppp_type] == 'ovpn_client' ? 'auth' : 'authentication'
    params[auth_key] = resource[:authentication] if ! resource[:authentication].nil?

    interface_type = resource[:ppp_type].to_s.tr('_','-')

    lookup = {}
    lookup["name"] = resource[:name]
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    simple_flush("/interface/#{interface_type}", params, lookup)
  end  
end
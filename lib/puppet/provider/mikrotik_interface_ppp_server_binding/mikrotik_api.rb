require 'puppet/provider/mikrotik_api'
Puppet::Type.type(:mikrotik_interface_ppp_server_binding).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  mk_resource_methods
  def self.instances    
    instances = []
    ovpn = Puppet::Provider::Mikrotik_Api::get_all("/interface/ovpn-server")
    ovpn.each { |client|
      instances << pppServerBinding('ovpn', client)
    }
    instances
  end

  def self.pppServerBinding(type,data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure   => :present,
      :state    => state,
      :name     => data['name'],
      :ppp_type => type,
      :user     => data['user'],
      :comment  => data['comment'],
    )
  end


  def flush
    Puppet.debug("Flushing PPP Server Binding #{resource[:name]}")
    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    attributes = [:name, :user, :comment]
    attributes.each do |attrib|
      params[attrib] = resource[attrib] unless resource[attrib].nil?  
    end

    interface_type = "#{resource[:ppp_type]}-server"

    lookup = {"name" => resource[:name]}
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")
    simple_flush("/interface/#{interface_type}", params, lookup)
  end  
end
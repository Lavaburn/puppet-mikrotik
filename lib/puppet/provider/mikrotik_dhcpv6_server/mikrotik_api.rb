require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_dhcpv6_server).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    servers = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/dhcp-server")
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
      :ensure       => :present,
      :state        => state,
      :name         => data['name'],
      :interface    => data['interface'],
      :lease_time   => data['lease-time'],
      :address_pool => data['address-pool']
    )
  end

  def flush
    Puppet.debug("Flushing DHCPv6 Server #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["interface"] = resource[:interface] if !resource[:interface].nil?
    params["lease-time"] = resource[:lease_time] if !resource[:lease_time].nil?
    params["address-pool"] = resource[:address_pool] if !resource[:address_pool].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/dhcp-server", params, lookup)
  end  
end

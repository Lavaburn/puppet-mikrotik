require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_dhcpv6_client).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    servers = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/dhcp-client")
    servers.each do |server|
      object = dhcpClient(server)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.dhcpClient(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    request = data['request'].split(',')
        
    new(
      :ensure             => :present,
      :state              => state,
      :name               => data['interface'],
      :request_address    => (request.include?("address")?'true':'false'),# TODO: verify string boolean ?,
      :request_prefix     => (request.include?("prefix")?'true':'false'),# TODO: verify string boolean ?,
      :pool_name          => data['pool-name'],
      :pool_prefix_length => data['pool-prefix-length'],
      :prefix_hint        => data['prefix-hint'],
      :use_peer_dns       => data['use-peer-dns'],
      :add_default_route  => data['add-default-route']
    )
  end

  def flush
    Puppet.debug("Flushing DHCPv6 Client #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    if !resource[:request_address].nil? || !resource[:request_prefix].nil?
      request = []
      request.push("address") if resource[:request_address]
      request.push("prefix")  if resource[:request_prefix]
      params["request"] = request.join(',')
    end
      
    params["interface"] = resource[:name]    
    params["pool-name"] = resource[:pool_name] if !resource[:pool_name].nil?
    params["pool-prefix-length"] = resource[:pool_prefix_length] if !resource[:pool_prefix_length].nil?
    params["prefix-hint"] = resource[:prefix_hint] if !resource[:prefix_hint].nil?
    params["use-peer-dns"] = resource[:use_peer_dns] if !resource[:use_peer_dns].nil?
    params["add-default-route"] = resource[:add_default_route] if !resource[:add_default_route].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ipv6/dhcp-client", params, lookup)
  end  
end

require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_address).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances    
    addresses = Puppet::Provider::Mikrotik_Api::get_all("/ip/address")
    instances = addresses.collect { |address| ipAddress(address) }    
    instances
  end
  
  def self.ipAddress(data)
      new(
        :ensure     => :present,
        :name       => data['address'],
        :interface  => data['interface']
      )
  end

  def flush
    Puppet.debug("Flushing IP Address #{resource[:name]}")
      
    params = {}
    params["address"]   = resource[:name]
    params["interface"] = resource[:interface]

    lookup = {}
    lookup["address"] = resource[:address]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/address", params, lookup)
  end  
end

require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_mpls_ldp_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/mpls/ldp/interface")
    interfaces.each do |interface|
      object = mplsLdpInterface(interface)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.mplsLdpInterface(data)    
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :name                     => data['interface'],
      :ensure                   => :present,
      :state                    => state,
      :hello_interval           => data['hello-interval'],
      :hold_time                => data['hold-time'],
      :transport_address        => data['transport-address'],
      :accept_dynamic_neighbors => data['accept-dynamic-neighbors']
    )
  end

  def flush 
    Puppet.debug("Flushing MPLS LDP Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["interface"] = resource[:name]
    params["hello-interval"] = resource[:hello_interval] if ! resource[:hello_interval].nil?
    params["hold-time"] = resource[:hold_time] if ! resource[:hold_time].nil?
    params["transport-address"] = resource[:transport_address] if ! resource[:transport_address].nil?
    params["accept-dynamic-neighbors"] = resource[:accept_dynamic_neighbors] if ! resource[:accept_dynamic_neighbors].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/mpls/ldp/interface", params, lookup)
  end
end
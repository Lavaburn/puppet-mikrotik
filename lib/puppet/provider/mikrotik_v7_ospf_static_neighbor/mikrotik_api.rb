require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_ospf_static_neighbor).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances    
    ospf_neighbors = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/static-neighbor")
    instances = ospf_neighbors.collect { |ospf_neighbor| ospfNeighbor(ospf_neighbor) }    
    instances
  end
  
  def self.ospfNeighbor(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure        => :present,
      :state         => state,
      :name          => data['address'],
      :comment       => data['comment'],
      :area          => data['area'],
      :instance_id   => data['instance-id'],
      :poll_interval => data['poll-interval']
    )
  end

  def flush
    Puppet.debug("Flushing OSPF Static Neighbor #{resource[:name]}")
      
    params = {}
      
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["address"] = resource[:name]
    params["area"] = resource[:area] if ! resource[:area].nil?
    params["instance-id"] = resource[:instance_id] if ! resource[:instance_id].nil?
    params["poll-interval"] = resource[:poll_interval] if ! resource[:poll_interval].nil?

    lookup = {}
    lookup["address"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/static-neighbor", params, lookup)
  end  
end

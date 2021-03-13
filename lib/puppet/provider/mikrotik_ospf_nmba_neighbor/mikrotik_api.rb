require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ospf_nmba_neighbor).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_neighbors = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/nbma-neighbor")
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
      :instance      => data['instance'],
      :poll_interval => data['poll-interval'],
      :priority      => data['priority']
    )
  end

  def flush
    Puppet.debug("Flushing OSPF NMBA Neighbor #{resource[:name]}")
      
    params = {}
      
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["address"] = resource[:name]
    params["instance"] = resource[:instance] if ! resource[:instance].nil?
    params["poll-interval"] = resource[:poll_interval] if ! resource[:poll_interval].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?

    lookup = {}
    lookup["address"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/nbma-neighbor", params, lookup)
  end  
end

require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ospfv3_interface).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_interfaces = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf-v3/interface")
    instances = ospf_interfaces.collect { |ospf_interface| ospfInterface(ospf_interface) }    
    instances
  end

  def self.ospfInterface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure       => :present,
      :state        => state,
      :name         => data['interface'],
      :area         => data['area'],
      :cost         => data['cost'],
      :priority     => data['priority'],
      :network_type => data['network-type'],
      :passive      => data['passive'],
      :use_bfd      => data['use-bfd']
    )
  end

  def flush
    Puppet.debug("Flushing OSPFv3 Interface #{resource[:name]}")
      
    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end
    
    params["interface"] = resource[:name]
    params["area"] = resource[:area] if ! resource[:area].nil?
    params["cost"] = resource[:cost] if ! resource[:cost].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["network-type"] = resource[:network_type] if ! resource[:network_type].nil?
    params["passive"] = resource[:passive] if ! resource[:passive].nil?
    params["use-bfd"] = resource[:use_bfd] if ! resource[:use_bfd].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf-v3/interface", params, lookup)
  end  
end

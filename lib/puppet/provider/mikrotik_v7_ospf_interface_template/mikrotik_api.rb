require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_ospf_interface_template).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances    
    ospf_interfaces = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/interface-template")
    instances = ospf_interfaces.reject {|data| data['dynamic'] == 'true' }.collect { |ospf_interface| ospfInterface(ospf_interface) }
    instances
  end

  def self.ospfInterface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    interfaces = []
    if !data['interfaces'].nil?
      interfaces = data['interfaces'].split(',')
    end
    networks = []
    if !data['networks'].nil?
      networks = data['networks'].split(',')
    end
    
    new(
      :ensure                => :present,
      :state                 => state,          
      :name                  => data['comment'],
      :interfaces            => interfaces,
      :area                  => data['area'],
      :networks              => networks,
      :network_type          => data['type'],
      :prefix_list           => data['prefix-list'],
      :instance_id           => data['instance-id'],
      :cost                  => data['cost'],
      :priority              => data['priority'],
      :passive               => (!data['passive'].nil?).to_s,
      :authentication        => data['authentication'],
      :authentication_key    => data['authentication-key'],          
      :authentication_key_id => data['authentication-key-id'],
      :vlink_transit_area    => data['vlink-transit-area'],
      :vlink_neighbor_id     => data['vlink-neighbor-id']
    )
  end

  def flush
    Puppet.debug("Flushing OSPF Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end

    if resource[:passive] == true || resource[:passive] == :true
      params["passive"] = true
    else
      #  TODO: BUGFIX: UNSETTING passive FAILS on 7.9
      Puppet.warning("OSPF Interface Template - Unsetting -passive- is currently not possible through the API!")
      params["passive"] = 'no'
    end
    
    params["comment"] = resource[:name]
    params["interfaces"] = resource[:interfaces].join(',') if ! resource[:interfaces].nil?
    params["area"] = resource[:area] if ! resource[:area].nil?
    params["networks"] = resource[:networks].join(',') if ! resource[:networks].nil?
    params["type"] = resource[:network_type] if ! resource[:network_type].nil?
    params["prefix-list"] = resource[:prefix_list] if ! resource[:prefix_list].nil?
    params["instance-id"] = resource[:instance_id] if ! resource[:instance_id].nil?
    params["cost"] = resource[:cost] if ! resource[:cost].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["authentication"] = resource[:authentication] if ! resource[:authentication].nil?
    params["authentication-key"] = resource[:authentication_key] if ! resource[:authentication_key].nil?
    params["authentication-key-id"] = resource[:authentication_key_id] if ! resource[:authentication_key_id].nil?
    params["vlink-transit-area"] = resource[:vlink_transit_area] if ! resource[:vlink_transit_area].nil?      
    params["vlink-neighbor-id"] = resource[:vlink_neighbor_id] if ! resource[:vlink_neighbor_id].nil?      

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/interface-template", params, lookup)
  end  
end

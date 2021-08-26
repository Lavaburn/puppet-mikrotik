require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_vlan).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    vlans = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/vlan")
    instances = vlans.collect { |vlan| vlan(vlan) unless vlan['dynamic'] == "yes" }    
    instances
  end
  
  def self.vlan(data)    
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    if data['comment'].nil?
      name = data['vlan-ids'] + " on " + data['bridge']
    else
      name = data['comment']
    end

    new(
      :ensure    => :present,
      :state     => state,
      :name      => name,
      :bridge    => data['bridge'],
      :vlan_ids  => data['vlan-ids'].split(','),
      :tagged    => data['tagged'].split(','),
      :untagged  => data['untagged'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing Bridge VLAN #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"]  = resource[:name]
    params["bridge"]   = resource[:bridge]      
    params["vlan-ids"] = resource[:vlan_ids].join(',') if ! resource[:vlan_ids].nil?    
    params["tagged"]   = resource[:tagged].join(',')   if ! resource[:tagged].nil?    
    params["untagged"] = resource[:untagged].join(',') if ! resource[:untagged].nil?    

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge/vlan", params, lookup)
  end  
end
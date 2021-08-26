require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_msti).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    msti_list = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/msti")
    instances = msti_list.collect { |msti| msti(msti) }    
    instances
  end
  
  def self.msti(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure       => :present,
      :state        => state,
      :name         => data['comment'],
      :bridge       => data['bridge'],
      :identifier   => data['identifier'],
      :priority     => data['priority'],
      :vlan_mapping => data['vlan-mapping'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing Bridge MSTI #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"]      = resource[:name]
    params["bridge"]       = resource[:bridge]      
    params["identifier"]   = resource[:identifier]
    params["priority"]     = resource[:priority] if ! resource[:priority].nil?
    params["vlan-mapping"] = resource[:vlan_mapping].join(',') if ! resource[:vlan_mapping].nil?    

    lookup = {}
    lookup["comment"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge/msti", params, lookup)
  end  
end
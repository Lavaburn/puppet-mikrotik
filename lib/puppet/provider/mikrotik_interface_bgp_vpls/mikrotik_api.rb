require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bgp_vpls).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/vpls/bgp-vpls")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure               => :present,
      :state                => state,
      :name                 => data['name'],
      :route_distinguisher  => data['route-distinguisher'],
      :import_route_targets => data['import-route-targets'].split(','),
      :export_route_targets => data['export-route-targets'].split(','),
      :site_id              => data['site-id'],
      :bridge               => data['bridge'],
      :bridge_cost          => data['bridge-cost'],
      :bridge_horizon       => data['bridge-horizon'],
      :control_word         => data['control-word'],
      :pw_mtu               => data['pw-mtu'],
      :pw_type              => data['pw-type']
    )
  end

  def flush
    Puppet.debug("Flushing BGP VPLS Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["route-distinguisher"] = resource[:route_distinguisher] if ! resource[:route_distinguisher].nil?
    params["import-route-targets"] = resource[:import_route_targets].join(',') if ! resource[:import_route_targets].nil?
    params["export-route-targets"] = resource[:export_route_targets].join(',') if ! resource[:export_route_targets].nil?
    params["site-id"] = resource[:site_id] if ! resource[:site_id].nil?
    params["bridge"] = resource[:bridge] if ! resource[:bridge].nil?
    params["bridge-cost"] = resource[:bridge_cost] if ! resource[:bridge_cost].nil?
    params["bridge-horizon"] = resource[:bridge_horizon] if ! resource[:bridge_horizon].nil?
    params["control-word"] = resource[:control_word] if ! resource[:control_word].nil?
    params["pw-mtu"] = resource[:pw_mtu] if ! resource[:pw_mtu].nil?
    params["pw-type"] = resource[:pw_type] if ! resource[:pw_type].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/vpls/bgp-vpls", params, lookup)
  end  
end
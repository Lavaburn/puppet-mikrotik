require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bgp_vpls).provide(:mikrotik_api_v7, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/vpls")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    import = []
    if !data['import-route-targets'].nil?
      import = data['import-route-targets'].split(',')
    end
    
    export = []
    if !data['export-route-targets'].nil?
      export = data['export-route-targets'].split(',')
    end
    
    new(
      :ensure               => :present,
      :state                => state,
      :name                 => data['name'],
      :route_distinguisher  => data['rd'],
      :import_route_targets => import,
      :export_route_targets => export,
      :site_id              => data['site-id'],
      :bridge               => data['bridge'],
      :bridge_cost          => data['bridge-cost'],
      :bridge_horizon       => data['bridge-horizon'],
      :control_word         => data['pw-control-word'],
      :pw_mtu               => data['pw-l2mtu'],
      :pw_type              => data['pw-type']
      # TODO: VRF, Local Preference, cisco-id
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
    params["rd"] = resource[:route_distinguisher] if ! resource[:route_distinguisher].nil?
    params["import-route-targets"] = resource[:import_route_targets].join(',') if ! resource[:import_route_targets].nil?
    params["export-route-targets"] = resource[:export_route_targets].join(',') if ! resource[:export_route_targets].nil?
    params["site-id"] = resource[:site_id] if ! resource[:site_id].nil?
    params["bridge"] = resource[:bridge] if ! resource[:bridge].nil?
    params["bridge-cost"] = resource[:bridge_cost] if ! resource[:bridge_cost].nil?
    params["bridge-horizon"] = resource[:bridge_horizon] if ! resource[:bridge_horizon].nil?
    params["pw-control-word"] = resource[:control_word] if ! resource[:control_word].nil?
    params["pw-l2mtu"] = resource[:pw_mtu] if ! resource[:pw_mtu].nil?
    params["pw-type"] = resource[:pw_type] if ! resource[:pw_type].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/vpls", params, lookup)
  end  
end
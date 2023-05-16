require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_bgp_vpn).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7

  mk_resource_methods

  def self.instances
    bgp_vrfs = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/vpn")
    vrfs = bgp_vrfs.collect { |bgp_vrf| bgpVRF(bgp_vrf) }    
    vrfs
  end

  def self.bgpVRF(data)  
    # Puppet.debug("Data: #{data.inspect}")
     
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    import_route_targets = []
    if !data['import-route-targets'].nil?
      import_route_targets = data['import-route-targets'].split(',')
    end
    
    export_route_targets = []
    if !data['export-route-targets'].nil?
      export_route_targets = data['export-route-targets'].split(',')
    end
    
    redistribute = []
    if !data['redistribute'].nil?
      redistribute = data['redistribute'].split(',')
    end
        
    new(
      :ensure                  => :present,
      :state                   => state,
      :name                    => data['route-distinguisher'],
      :vrf                     => data['vrf'],
      :label_allocation_policy => data['label-allocation-policy'],
      :import_route_targets    => import_route_targets,
      :export_route_targets    => export_route_targets,
      :import_filter           => data['import-filter'],
      :export_filter           => data['export-filter'],
      :redistribute            => redistribute
    )
  end

  def flush
    Puppet.info("Flushing BGP Instance VRF #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["route-distinguisher"] = resource[:name]
    params["vrf"] = resource[:vrf] if ! resource[:vrf].nil?
    params["label-allocation-policy"] = resource[:label_allocation_policy] if ! resource[:label_allocation_policy].nil?
    params["import-route-targets"] = resource[:import_route_targets].join(',') if ! resource[:import_route_targets].nil?
    params["export-route-targets"] = resource[:export_route_targets].join(',') if ! resource[:export_route_targets].nil?
    params["import-filter"] = resource[:import_filter] if ! resource[:import_filter].nil?
    params["export-filter"] = resource[:export_filter] if ! resource[:export_filter].nil?
    params["redistribute"] = resource[:redistribute].join(',') if ! resource[:redistribute].nil?

    lookup = {}
    lookup["route-distinguisher"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/vpn", params, lookup)
  end
end

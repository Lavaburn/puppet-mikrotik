require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_instance_vrf).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    bgp_vrfs = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/instance/vrf")
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

    new(
      :ensure                 => :present,
      :state                  => state,
      :name                   => data['routing-mark'],
      :instance               => data['instance'],
      :redistribute_connected => data['redistribute-connected'].to_sym,
      :redistribute_static    => data['redistribute-static'].to_sym,
      :redistribute_rip       => data['redistribute-rip'].to_sym,
      :redistribute_ospf      => data['redistribute-ospf'].to_sym,
      :redistribute_bgp       => data['redistribute-other-bgp'].to_sym,
      :in_filter              => data['in-filter'],
      :out_filter             => data['out-filter']
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

    params["routing-mark"] = resource[:name]
    params["instance"] = resource[:instance]
    params["redistribute-connected"] = resource[:redistribute_connected] if ! resource[:redistribute_connected].nil?
    params["redistribute-static"] = resource[:redistribute_static] if ! resource[:redistribute_static].nil?
    params["redistribute-rip"] = resource[:redistribute_rip] if ! resource[:redistribute_rip].nil?
    params["redistribute-ospf"] = resource[:redistribute_ospf] if ! resource[:redistribute_ospf].nil?
    params["redistribute-other-bgp"] = resource[:redistribute_bgp] if ! resource[:redistribute_bgp].nil?
    params["in-filter"] = resource[:in_filter] if ! resource[:in_filter].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?

    lookup = {}
    lookup["routing-mark"] = resource[:name]
    lookup["instance"] = resource[:instance]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/instance/vrf", params, lookup)
  end
end

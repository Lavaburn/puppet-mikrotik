require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_peer).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    bgp_peers = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/peer")
    instances = bgp_peers.collect { |bgp_peer| bgpPeer(bgp_peer) }    
    instances
  end
  
  def self.bgpPeer(data)
      new(
        :ensure            => :present,
        :name              => data['name'],
        :instance          => data['instance'],
        :peer_address      => data['remote-address'],
        :peer_as           => data['remote-as'],
        :source            => data['update-source'],
        :out_filter        => data['out-filter'],
        :in_filter         => data['in-filter'],
        :route_reflect     => data['route-reflect'],
        :default_originate => data['default-originate']
      )
  end

  def flush
    Puppet.debug("Flushing BGP Peer #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["instance"] = resource[:instance] if ! resource[:instance].nil?
    params["remote-address"] = resource[:peer_address] if ! resource[:peer_address].nil?
    params["remote-as"] = resource[:peer_as] if ! resource[:peer_as].nil?
    params["update-source"] = resource[:source] if ! resource[:source].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["in-filter"] = resource[:in_filter] if ! resource[:in_filter].nil?
    params["route-reflect"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:route_reflect]) if ! resource[:route_reflect].nil?
    params["default-originate"] = resource[:default_originate] if ! resource[:default_originate].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/peer", params, lookup)
  end  
end
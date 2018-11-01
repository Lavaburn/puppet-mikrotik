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
#    Puppet.debug("BGP Peer: #{data.inspect}")
      
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end   
    
    new(
      :ensure                   => :present,
      :state                    => state,
      :name                     => data['name'],
      :instance                 => data['instance'],
      :peer_address             => data['remote-address'],          
      :peer_port                => data['remote-port'],
      :peer_as                  => data['remote-as'],
      :tcp_md5_key              => data['tcp-md5-key'],
      :nexthop_choice           => data['nexthop-choice'],
      :multihop                 => data['multihop'],
      :route_reflect            => data['route-reflect'],
      :hold_time                => data['hold-time'],
      :keepalive_time           => data['keepalive-time'],
      :ttl                      => data['ttl'],
      :max_prefix_limit         => data['max-prefix-limit'],
      :max_prefix_restart_time  => data['max-prefix-restart-time'],
      :in_filter                => data['in-filter'],
      :out_filter               => data['out-filter'],      
      :allow_as_in              => data['allow-as-in'],
      :remove_private_as        => data['remove-private-as'],
      :as_override              => data['as-override'],
      :default_originate        => data['default-originate'],
      :passive                  => data['passive'],
      :use_bfd                  => data['use-bfd'],
      :address_families         => data['address-families'].split(','),
      :source                   => data['update-source'],
      :comment                  => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing BGP Peer #{resource[:name]}")

    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["name"] = resource[:name]
    params["instance"] = resource[:instance] if ! resource[:instance].nil?
    params["remote-address"] = resource[:peer_address] if ! resource[:peer_address].nil?
    params["remote-port"] = resource[:peer_port] if ! resource[:peer_port].nil?
    params["remote-as"] = resource[:peer_as] if ! resource[:peer_as].nil?
    params["tcp-md5-key"] = resource[:tcp_md5_key] if ! resource[:tcp_md5_key].nil?
    params["nexthop-choice"] = resource[:nexthop_choice] if ! resource[:nexthop_choice].nil?
    params["multihop"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:multihop]) if ! resource[:multihop].nil?
    params["route-reflect"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:route_reflect]) if ! resource[:route_reflect].nil?
    params["hold-time"] = resource[:hold_time] if ! resource[:hold_time].nil?
    params["keepalive-time"] = resource[:keepalive_time] if ! resource[:keepalive_time].nil?
    params["ttl"] = resource[:ttl] if ! resource[:ttl].nil?
    params["max-prefix-limit"] = resource[:max_prefix_limit] if ! resource[:max_prefix_limit].nil?
    params["max-prefix-restart-time"] = resource[:max_prefix_restart_time] if ! resource[:max_prefix_restart_time].nil?
    params["in-filter"] = resource[:in_filter] if ! resource[:in_filter].nil?
    params["out-filter"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["allow-as-in"] = resource[:allow_as_in] if ! resource[:allow_as_in].nil?
    params["remove-private-as"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:remove_private_as]) if ! resource[:remove_private_as].nil?
    params["as-override"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:as_override]) if ! resource[:as_override].nil?
    params["default-originate"] = resource[:default_originate] if ! resource[:default_originate].nil?
    params["passive"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:passive]) if ! resource[:passive].nil?
    params["use-bfd"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:use_bfd]) if ! resource[:use_bfd].nil?
    params["address-families"] = resource[:address_families].join(',') if ! resource[:address_families].nil?    
    params["update-source"] = resource[:source] if ! resource[:source].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?
    
    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/peer", params, lookup)
  end  
end
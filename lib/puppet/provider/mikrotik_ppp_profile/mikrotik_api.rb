require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ppp_profile).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances    
    profiles = Puppet::Provider::Mikrotik_Api::get_all("/ppp/profile")
    instances = profiles.collect { |profile| pppProfile(profile) }    
    instances
  end
  
  def self.pppProfile(data)    
    new(
      :ensure               => :present,
      :name                 => data['name'],
      :local_address        => data['local-address'],
      :remote_address       => data['remote-address'],
      :bridge               => data['bridge'],
      :bridge_path_cost     => data['bridge-path-cost'],
      :bridge_port_priority => data['bridge-port-priority'],
      :incoming_filter      => data['incoming-filter'],
      :outgoing_filter      => data['outgoing-filter'],        
      :address_list         => data['address-list'],    
      :dns_server           => data['dns-server'],    
      :wins_server          => data['wins-server'],
      :change_tcp_mss       => data['change-tcp-mss'],
      :use_upnp             => data['use-upnp'],
      :use_mpls             => data['use-mpls'],
      :use_compression      => data['use-compression'],
      :use_encryption       => data['use-encryption'],
      :session_timeout      => data['session-timeout'],
      :idle_timeout         => data['idle-timeout'],
      :rate_limit           => data['rate-limit'],
      :insert_queue_before  => data['insert-queue-before'],
      :parent_queue         => data['parent-queue'],
      :queue_type           => data['queue-type'],
      :only_one             => data['only-one'],
      :on_up                => data['on-up'],
      :on_down              => data['on-down']
    )
  end

  def flush
    Puppet.debug("Flushing PPP profile #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["local-address"] = resource[:local_address] if ! resource[:local_address].nil?
    params["remote-address"] = resource[:remote_address] if ! resource[:remote_address].nil?
    params["bridge"] = resource[:bridge] if ! resource[:bridge].nil?      
    params["bridge-path-cost"] = resource[:bridge_path_cost] if ! resource[:bridge_path_cost].nil?
    params["bridge-port-priority"] = resource[:bridge_port_priority] if ! resource[:bridge_port_priority].nil?
    params["incoming-filter"] = resource[:incoming_filter] if ! resource[:incoming_filter].nil?
    params["outgoing-filter"] = resource[:outgoing_filter] if ! resource[:outgoing_filter].nil?
    params["address-list"] = resource[:address_list] if ! resource[:address_list].nil?
    params["dns-server"] = resource[:dns_server] if ! resource[:dns_server].nil?
    params["wins-server"] = resource[:wins_server] if ! resource[:wins_server].nil?
    params["change-tcp-mss"] = resource[:change_tcp_mss] if ! resource[:change_tcp_mss].nil?
    params["use-upnp"] = resource[:use_upnp] if ! resource[:use_upnp].nil?
    params["use-mpls"] = resource[:use_mpls] if ! resource[:use_mpls].nil?
    params["use-compression"] = resource[:use_compression] if ! resource[:use_compression].nil?
    params["use-encryption"] = resource[:use_encryption] if ! resource[:use_encryption].nil?
    params["session-timeout"] = resource[:session_timeout] if ! resource[:session_timeout].nil?
    params["idle-timeout"] = resource[:idle_timeout] if ! resource[:idle_timeout].nil?
    params["rate-limit"] = resource[:rate_limit] if ! resource[:rate_limit].nil?
    params["insert-queue-before"] = resource[:insert_queue_before] if ! resource[:insert_queue_before].nil?
    params["parent-queue"] = resource[:parent_queue] if ! resource[:parent_queue].nil?
    params["queue-type"] = resource[:queue_type] if ! resource[:queue_type].nil?      
    params["only-one"] = resource[:only_one] if ! resource[:only_one].nil?
    params["on-up"] = resource[:on_up] if ! resource[:on_up].nil?
    params["on-down"] = resource[:on_down] if ! resource[:on_down].nil?
      
    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ppp/profile", params, lookup)
  end  
end

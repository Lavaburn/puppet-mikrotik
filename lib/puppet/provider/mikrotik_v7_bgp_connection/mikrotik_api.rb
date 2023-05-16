require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_bgp_connection).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances    
    bgp_peers = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/connection")
    instances = bgp_peers.collect { |bgp_peer| bgpPeer(bgp_peer) }    
    instances
  end
  
  def self.bgpPeer(data) 
#    Puppet.debug("BGP Connection: #{data.inspect}")
      
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end     

    address_families = []
    if !data['address-families'].nil?
      address_families = data['address-families'].split(',')
    end

    templates = []
    if !data['templates'].nil?
      templates = data['templates'].split(',')
    end

    redistribute = []
    if !data['output.redistribute'].nil?
      redistribute = data['output.redistribute'].split(',')
    end
    
    new(
    :ensure                   => :present,
    :state                    => state,
    :name                     => data['name'],
    :templates                => templates,
    :as                       => data['as'],
    :address_families         => address_families,
    :router_id                => data['router-id'],
    :remote_address           => data['remote.address'],
    :remote_port              => data['remote.port'],
    :remote_as                => data['remote.as'],
    :remote_allowed_as        => data['remote.allowed-as'],
    :local_address            => data['local.address'],
    :local_port               => data['local.port'],
    :local_role               => data['local.role'],
    :tcp_md5_key              => data['tcp-md5-key'],
    :multihop                 => data['multihop'],
    :local_ttl                => data['local.ttl'],
    :remote_ttl               => data['remote.ttl'],
    :connect                  => data['connect'],
    :listen                   => data['listen'],
    :hold_time                => data['hold-time'],
    :keepalive_time           => data['keepalive-time'],
    :use_bfd                  => data['use-bfd'],
    :routing_table            => data['routing-table'],
    :vrf                      => data['vrf'],
    :cluster_id               => data['cluster-id'],
    :disable_client_to_client_relection => data['output.no-client-to-client-reflection'],
    :redistribute             => redistribute,
    :default_originate        => data['output.default-originate'],
    :no_early_cut             => data['output.no-early-cut'],
    :keep_sent_attributes     => data['output.keep-sent-attributes'],
    :input_affinity           => data['input.affinity'],
    :output_affinity          => data['output.affinity'],
    :nexthop_choice           => data['nexthop-choice'],
    :as_override              => data['as-override'],
    :default_prepend          => data['output.default-prepend'],
    :add_path_out             => data['add-path-out'],  
    :allow_as_in              => data['input.allow-as'],
    :ignore_as_path_length    => data['input.ignore-as-path-len'],
    :remove_private_as        => data['remove-private-as'],
    :cisco_vpls_nlri_len_fmt  => data['cisco-vpls-nlri-len-fmt'],
    :input_filter             => data['input.filter'],
    :input_accept_nlri        => data['input.accept-nlri'],
    :input_accept_communities => data['input.accept-communities'],
    :input_accept_ext_communities       => data['input.accept-ext-communities'],
    :input_accept_large_communities     => data['input.accept-large-communities'],
    :input_accept_unknown     => data['input.accept-unknown'],
    :output_filter            => data['output.filter-chain'],
    :output_filter_select     => data['output.filter-select'],
    :output_network           => data['output.network'],
    :comment                  => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing BGP Connection #{resource[:name]}")

    params = {}
    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["name"] = resource[:name]
    params["templates"] = resource[:templates].join(',') if ! resource[:templates].nil?
    params["as"] = resource[:as] if ! resource[:as].nil?
    params["address-families"] = resource[:address_families].join(',') if ! resource[:address_families].nil?    
    params["router-id"] = resource[:router_id] if ! resource[:router_id].nil?
    params["remote.address"] = resource[:remote_address] if ! resource[:remote_address].nil?
    params["remote.port"] = resource[:remote_port] if ! resource[:remote_port].nil?
    params["remote.as"] = resource[:remote_as] if ! resource[:remote_as].nil?
    params["remote.allowed-as"] = resource[:remote_allowed_as] if ! resource[:remote_allowed_as].nil?
    params["local.address"] = resource[:local_address] if ! resource[:local_address].nil?
    params["local.port"] = resource[:local_port] if ! resource[:local_port].nil?
    params["local.role"] = resource[:local_role] if ! resource[:local_role].nil?
    params["tcp-md5-key"] = resource[:tcp_md5_key] if ! resource[:tcp_md5_key].nil?
    params["multihop"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:multihop]) if ! resource[:multihop].nil?
    params["local.ttl"] = resource[:local_ttl] if ! resource[:local_ttl].nil?
    params["remote.ttl"] = resource[:remote_ttl] if ! resource[:remote_ttl].nil?
    params["connect"] = resource[:connect] if ! resource[:connect].nil?
    params["listen"] = resource[:listen] if ! resource[:listen].nil?
    params["hold-time"] = resource[:hold_time] if ! resource[:hold_time].nil?
    params["keepalive-time"] = resource[:keepalive_time] if ! resource[:keepalive_time].nil?
    params["use-bfd"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:use_bfd]) if ! resource[:use_bfd].nil?
    params["routing-table"] = resource[:routing_table] if ! resource[:routing_table].nil?
    params["vrf"] = resource[:vrf] if ! resource[:vrf].nil?
    params["cluster-id"] = resource[:cluster_id] if ! resource[:cluster_id].nil?
    params["output.no-client-to-client-reflection"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:disable_client_to_client_relection]) if ! resource[:disable_client_to_client_relection].nil?
    params["output.redistribute"] = resource[:redistribute].join(',') if ! resource[:redistribute].nil?   
    params["output.default-originate"] = resource[:default_originate] if ! resource[:default_originate].nil?
    params["output.no-early-cut"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:no_early_cut]) if ! resource[:no_early_cut].nil?
    params["output.keep-sent-attributes"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:keep_sent_attributes]) if ! resource[:keep_sent_attributes].nil?
    params["input.affinity"] = resource[:input_affinity] if ! resource[:input_affinity].nil?
    params["output.affinity"] = resource[:output_affinity] if ! resource[:output_affinity].nil?
    params["nexthop-choice"] = resource[:nexthop_choice] if ! resource[:nexthop_choice].nil?      
    params["as-override"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:as_override]) if ! resource[:as_override].nil?   
    params["output.default-prepend"] = resource[:default_prepend] if ! resource[:default_prepend].nil?   
    params["add-path-out"] = resource[:add_path_out] if ! resource[:add_path_out].nil?         
    params["input.allow-as"] = resource[:allow_as_in] if ! resource[:allow_as_in].nil? 
    params["input.ignore-as-path-len"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:ignore_as_path_length]) if ! resource[:ignore_as_path_length].nil?        
    params["remove-private-as"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:remove_private_as]) if ! resource[:remove_private_as].nil?      
    params["cisco-vpls-nlri-len-fmt"] = resource[:cisco_vpls_nlri_len_fmt] if ! resource[:cisco_vpls_nlri_len_fmt].nil?      
    params["input.filter"] = resource[:input_filter] if ! resource[:input_filter].nil?
    params["input.accept-nlri"] = resource[:input_accept_nlri] if ! resource[:input_accept_nlri].nil?
    params["input.accept-communities"] = resource[:input_accept_communities] if ! resource[:input_accept_communities].nil?
    params["input.accept-ext-communities"] = resource[:input_accept_ext_communities] if ! resource[:input_accept_ext_communities].nil?
    params["input.accept-large-communities"] = resource[:input_accept_large_communities] if ! resource[:input_accept_large_communities].nil?
    params["input.accept-unknown"] = resource[:input_accept_unknown] if ! resource[:input_accept_unknown].nil?      
    params["output.filter-chain"] = resource[:output_filter] if ! resource[:output_filter].nil?
    params["output.filter-select"] = resource[:output_filter_select] if ! resource[:output_filter_select].nil?
    params["output.network"] = resource[:output_network] if ! resource[:output_network].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?
    
    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/connection", params, lookup)
  end  
end
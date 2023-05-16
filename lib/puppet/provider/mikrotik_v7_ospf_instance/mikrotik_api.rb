require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_v7_ospf_instance).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances    
    ospf_instances = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf/instance")
    instances = ospf_instances.collect { |ospf_instance| ospfInstance(ospf_instance) }    
    instances
  end
  
  def self.ospfInstance(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    redistribute = []
    if !data['redistribute'].nil?
      redistribute = data['redistribute'].split(',')
    end
        
    new(
      :ensure            => :present,
      :state             => state,
      :name              => data['name'],
      :comment           => data['comment'],
      :version           => data['version'],
      :vrf               => data['vrf'],
      :router_id         => data['router-id'],
      :routing_table     => data['routing-table'],
      :originate_default => data['originate-default'],
      :redistribute      => redistribute,
      :out_filter_select => data['out-filter-select'],
      :out_filter        => data['out-filter-chain'],
      :in_filter         => data['in-filter-chain'],
      :domain_id         => data['domain-id'],
      :domain_tag        => data['domain-tag'],
      :mpls_te_address   => data['mpls-te-address'],
      :mpls_te_area      => data['mpls-te-area']
    )
  end

  def flush
    Puppet.debug("Flushing OSPF Instance #{resource[:name]}")
      
    params = {}
      
    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end

    params["name"] = resource[:name]
    params["version"] = resource[:version] if ! resource[:version].nil?
    params["vrf"] = resource[:vrf] if ! resource[:vrf].nil?      
    params["router-id"] = resource[:router_id] if ! resource[:router_id].nil?
    params["routing-table"] = resource[:routing_table] if ! resource[:routing_table].nil?
    params["originate-default"] = resource[:originate_default] if ! resource[:originate_default].nil?      
    params["redistribute"] = resource[:redistribute].join(',') if ! resource[:redistribute].nil?
    params["out-filter-select"] = resource[:out_filter_select] if ! resource[:out_filter_select].nil?
    params["out-filter-chain"] = resource[:out_filter] if ! resource[:out_filter].nil?
    params["in-filter-chain"] = resource[:in_filter] if ! resource[:in_filter].nil?      
    params["domain-id"] = resource[:domain_id] if ! resource[:domain_id].nil?
    params["domain-tag"] = resource[:domain_tag] if ! resource[:domain_tag].nil?
    params["mpls-te-address"] = resource[:mpls_te_address] if ! resource[:mpls_te_address].nil?
    params["mpls-te-area"] = resource[:mpls_te_area] if ! resource[:mpls_te_area].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf/instance", params, lookup)
  end  
end

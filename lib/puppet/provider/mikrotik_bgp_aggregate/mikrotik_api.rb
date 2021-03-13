require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_bgp_aggregate).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    bgp_aggregates = Puppet::Provider::Mikrotik_Api::get_all("/routing/bgp/aggregate")
    aggregates = bgp_aggregates.collect { |bgp_aggregate| bgpAggregate(bgp_aggregate) }    
    aggregates
  end
  
  def self.bgpAggregate(data)     
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end   

    new(
      :ensure             => :present,
      :state              => state,
      :name               => data['prefix'],
      :instance           => data['instance'],
      :summary_only       => data['summary-only'],
      :inherit_attributes => data['inherit-attributes'],
      :include_igp        => data['include-igp'],
      :attribute_filter   => data['attribute-filter'],
      :suppress_filter    => data['suppress-filter'],
      :advertise_filter   => data['advertise-filter']
    )
  end

  def flush
    Puppet.info("Flushing BGP Aggregate #{resource[:name]}")
    
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["prefix"] = resource[:name]
    params["instance"] = resource[:instance]

    params["attribute-filter"] = resource[:attribute_filter] if ! resource[:attribute_filter].nil?
    params["suppress-filter"] = resource[:suppress_filter] if ! resource[:suppress_filter].nil?
    params["advertise-filter"] = resource[:advertise_filter] if ! resource[:advertise_filter].nil?

    params["summary-only"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:summary_only]) if ! resource[:summary_only].nil?
    params["inherit-attributes"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:inherit_attributes]) if ! resource[:inherit_attributes].nil?
    params["include-igp"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:include_igp]) if ! resource[:include_igp].nil?

    lookup = {}
    lookup["prefix"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/bgp/aggregate", params, lookup)
  end  
end

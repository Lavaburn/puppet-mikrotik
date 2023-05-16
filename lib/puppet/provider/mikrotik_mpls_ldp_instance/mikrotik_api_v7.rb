require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_mpls_ldp_instance).provide(:mikrotik_api_v7, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances
    instances = []
      
    ldp = Puppet::Provider::Mikrotik_Api::get_all("/mpls/ldp")
    ldp.each do |data|
      object = mplsLdp(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.mplsLdp(data)
    if data['disabled'] == "false"
      state = :enabled
    else
      state = :disabled
    end
    
    transport_addresses = []
    if !data['transport-addresses'].nil?
      transport_addresses = data['transport-addresses'].split(',')
    end
    
    new(
      :name                         => data['comment'],
      :ensure                       => :present,
      :state                        => state,
      :lsr_id                       => data['lsr-id'],
      :transport_addresses          => transport_addresses,
      :path_vector_limit            => data['path-vector-limit'],
      :hop_limit                    => data['hop-limit'],
      :loop_detect                  => data['loop-detect'],
      :use_explicit_null            => data['use-explicit-null'],
      :distribute_for_default_route => data['distribute-for-default-route']
      # TODO: vrf
      # TODO: afi
    )
  end

  def flush
    Puppet.debug("Flushing MPLS LDP #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'true'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'false'
    end

    params["comment"] = resource[:name]
    params["lsr-id"] = resource[:lsr_id] if ! resource[:lsr_id].nil?
    params["transport-addresses"] = resource[:transport_addresses].join(',') if ! resource[:transport_addresses].nil?
    params["path-vector-limit"] = resource[:path_vector_limit] if ! resource[:path_vector_limit].nil?
    params["hop-limit"] = resource[:hop_limit] if ! resource[:hop_limit].nil?
    params["loop-detect"] = resource[:loop_detect] if ! resource[:loop_detect].nil?
    params["use-explicit-null"] = resource[:use_explicit_null] if ! resource[:use_explicit_null].nil?
    params["distribute-for-default-route"] = resource[:distribute_for_default_route] if ! resource[:distribute_for_default_route].nil?

    lookup = {}
    lookup["comment"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/mpls/ldp", params, lookup)
  end
end
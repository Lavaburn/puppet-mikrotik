require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_mpls_ldp).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
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
    if data['enabled'] == "true"
      state = :enabled
    else
      state = :disabled
    end
    
    new(
      :name                         => 'ldp',
      :ensure                       => :present,
      :state                        => state,
      :lsr_id                       => data['lsr-id'],
      :transport_address            => data['transport-address'],
      :path_vector_limit            => data['path-vector-limit'],
      :hop_limit                    => data['hop-limit'],
      :loop_detect                  => data['loop-detect'],
      :use_explicit_null            => data['use-explicit-null'],
      :distribute_for_default_route => data['distribute-for-default-route']
    )
  end

  def flush
    Puppet.debug("Flushing MPLS LDP")
    
    if (@property_hash[:name] != 'ldp') 
      raise "There is only one set of MPLS LDP settings. Title (name) should be -ldp-"
    end
    
    update = {}

    if @property_hash[:state] == :disabled
      update["enabled"] = 'no'
    elsif @property_hash[:state] == :enabled
      update["enabled"] = 'yes'
    end
    
    update["lsr-id"] = resource[:lsr_id] if ! resource[:lsr_id].nil?
    update["transport-address"] = resource[:transport_address] if ! resource[:transport_address].nil?
    update["path-vector-limit"] = resource[:path_vector_limit] if ! resource[:path_vector_limit].nil?
    update["hop-limit"] = resource[:hop_limit] if ! resource[:hop_limit].nil?
    update["loop-detect"] = resource[:loop_detect] if ! resource[:loop_detect].nil?
    update["use-explicit-null"] = resource[:use_explicit_null] if ! resource[:use_explicit_null].nil?
    update["distribute-for-default-route"] = resource[:distribute_for_default_route] if ! resource[:distribute_for_default_route].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/mpls/ldp", update)
  end
end
require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_mpls_te_path).provide(:mikrotik_api_v7, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
  mk_resource_methods

  def self.instances
    paths = Puppet::Provider::Mikrotik_Api::get_all("/mpls/traffic-eng/path")
    instances = paths.collect { |path| tunnelPath(path) }    
    instances
  end

  def self.tunnelPath(data)    
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    hops = nil
    if !data['hops'].nil?
      hops = data['hops'].gsub('/', ':').split(',')
    end
    
    new(
      :name         => data['name'],
      :ensure       => :present,
      :state        => state,
      :use_cspf     => (data['use-cspf'].nil?     ? :false : data['use-cspf']),
      :record_route => (data['record-route'].nil? ? :false : data['record-route']),
      :hops         => hops
    )
  end

  def flush 
    Puppet.debug("Flushing MPLS TE Tunnel Path #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["use-cspf"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:use_cspf]) if ! resource[:use_cspf].nil?
    params["record-route"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:record_route]) if ! resource[:record_route].nil?
    params["hops"] = resource[:hops].join(',').gsub(':', '/') if ! resource[:hops].nil?  

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/mpls/traffic-eng/path", params, lookup)
  end
end
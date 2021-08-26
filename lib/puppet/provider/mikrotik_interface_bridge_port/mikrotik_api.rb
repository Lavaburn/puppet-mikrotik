require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_port).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/port")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure             => :present,
      :state              => state,
      :name               => data['interface'],
      :bridge             => data['bridge'],
      :horizon            => data['horizon'],   
      :priority           => data['priority'],
      :path_cost          => data['path-cost'],  
      :internal_path_cost => data['internal-path-cost'],  
      :pvid               => data['pvid'],     
      :frame_types        => data['frame-types'],
      :ingress_filtering  => (data['ingress-filtering'].nil? ? :false : data['ingress-filtering']),
      :tag_stacking       => (data['tag-stacking'].nil? ? :false : data['tag-stacking']),
      :comment            => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing Bridge Port #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["interface"] = resource[:name]
    params["bridge"] = resource[:bridge]
    params["horizon"] = resource[:horizon] if ! resource[:horizon].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["path-cost"] = resource[:path_cost] if ! resource[:path_cost].nil?
    params["internal-path-cost"] = resource[:internal_path_cost] if ! resource[:internal_path_cost].nil?
    params["pvid"] = resource[:pvid] if ! resource[:pvid].nil?      
    params["frame-types"] = resource[:frame_types] if ! resource[:frame_types].nil?
    params["ingress-filtering"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:ingress_filtering]) if ! resource[:ingress_filtering].nil?
    params["tag-stacking"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:tag_stacking]) if ! resource[:tag_stacking].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["interface"] = resource[:name]
    # ? lookup["bridge"] = resource[:bridge]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge/port", params, lookup)
  end  
end
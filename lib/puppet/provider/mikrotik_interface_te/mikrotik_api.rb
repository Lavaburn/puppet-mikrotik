require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_te).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/traffic-eng")
    instances = interfaces.collect { |interface| teInterface(interface) }    
    instances
  end

  def self.teInterface(data)    
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :name                   => data['name'],
      :ensure                 => :present,
      :state                  => state,
      :mtu                    => data['mtu'],
      :from_address           => data['from-address'],
      :to_address             => data['to-address'],
      :bandwidth              => data['bandwidth'],
      :primary_path           => data['primary-path'],
      :secondary_paths        => data['secondary-paths'].split(','),
      :record_route           => (data['record-route'].nil? ? :false : data['record-route']),
      :bandwidth_limit        => data['bandwidth-limit'],
      :auto_bandwidth_range   => data['auto-bandwidth-range'],
      :auto_bandwidth_reserve => data['auto-bandwidth-reserve']
    )
  end

  def flush 
    Puppet.debug("Flushing MPLS TE Interface #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?  
      

    params["from-address"] = resource[:from_address] if ! resource[:from_address].nil?  
    params["to-address"] = resource[:to_address] if ! resource[:to_address].nil?  
    params["bandwidth"] = resource[:bandwidth] if ! resource[:bandwidth].nil?  
    params["primary-path"] = resource[:primary_path] if ! resource[:primary_path].nil?
    params["secondary-paths"] = resource[:secondary_paths].join(',') if ! resource[:secondary_paths].nil?   
    params["record-route"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:record_route]) if ! resource[:record_route].nil?       
    params["bandwidth-limit"] = resource[:bandwidth_limit] if ! resource[:bandwidth_limit].nil?  
    params["auto-bandwidth-range"] = resource[:auto_bandwidth_range] if ! resource[:auto_bandwidth_range].nil?  
    params["auto-bandwidth-reserve"] = resource[:auto_bandwidth_reserve] if ! resource[:auto_bandwidth_reserve].nil? 

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/traffic-eng", params, lookup)
  end
end
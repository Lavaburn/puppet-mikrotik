require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_route_vrf).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    tables = Puppet::Provider::Mikrotik_Api::get_all("/ip/route/vrf")
    tables.each do |table|
      object = vrf(table)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.vrf(data)
    if data['routing-mark'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      new(
        :ensure               => :present,
        :state                => state,
        :name                 => data['routing-mark'],
        :interfaces           => data['interfaces'].nil? ? nil : data['interfaces'].split(','),
        :route_distinguisher  => data['route-distinguisher'],
        :import_route_targets => data['import-route-targets'].nil? ? nil : data['import-route-targets'].split(','),
        :export_route_targets => data['export-route-targets'].nil? ? nil : data['export-route-targets'].split(',')
      )
    end
  end

  def flush
    Puppet.debug("Flushing IP Route VRF #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["routing-mark"] = resource[:name]
    params["interfaces"] = resource[:interfaces].join(',') if !resource[:interfaces].nil?
    params["route-distinguisher"] = resource[:route_distinguisher] if !resource[:route_distinguisher].nil?
    params["import-route-targets"] = resource[:import_route_targets].join(',') if !resource[:import_route_targets].nil?
    params["export-route-targets"] = resource[:export_route_targets].join(',') if !resource[:export_route_targets].nil?

    lookup = {}
    lookup["routing-mark"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/route/vrf", params, lookup)
  end  
end

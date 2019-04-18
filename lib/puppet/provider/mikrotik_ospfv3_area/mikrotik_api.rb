require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ospfv3_area).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    ospf_areas = Puppet::Provider::Mikrotik_Api::get_all("/routing/ospf-v3/area")
    instances = ospf_areas.collect { |ospf_area| ospfArea(ospf_area) }    
    instances
  end
  
  def self.ospfArea(data)
      new(
        :ensure    => :present,
        :name      => data['name'],
        :area_id   => data['area-id'],
        :instance  => data['instance'],
        :area_type => data['type']
      )
  end

  def flush
    Puppet.debug("Flushing OSPFv3 Area #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["area-id"] = resource[:area_id] if ! resource[:area_id].nil?
    params["instance"] = resource[:instance] if ! resource[:instance].nil?
    params["type"] = resource[:area_type] if ! resource[:area_type].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/routing/ospf-v3/area", params, lookup)
  end  
end

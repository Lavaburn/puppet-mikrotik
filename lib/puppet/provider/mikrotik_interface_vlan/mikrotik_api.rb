require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_vlan).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/vlan")
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
      :ensure          => :present,
      :state           => state,
      :name            => data['name'],
      :mtu             => data['mtu'],
      :arp             => data['arp'],
      :arp_timeout     => data['arp-timeout'],
      :vlan_id         => data['vlan-id'],
      :interface       => data['interface'],
      :use_service_tag => data['use-service-tag']
    )
  end

  def flush
    Puppet.debug("Flushing VLAN Interface #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["name"] = resource[:name]
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["arp"] = resource[:arp] if ! resource[:arp].nil?
    params["arp-timeout"] = resource[:arp_timeout] if ! resource[:arp_timeout].nil?
    params["vlan-id"] = resource[:vlan_id] if ! resource[:vlan_id].nil?
    params["interface"] = resource[:interface] if ! resource[:interface].nil?
    params["use-service-tag"] = resource[:use_service_tag] if ! resource[:use_service_tag].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/vlan", params, lookup)
  end  
end
require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bond).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/bonding")
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
      :ensure               => :present,
      :state                => state,
      :name                 => data['name'],
      :mtu                  => data['mtu'],
      :arp                  => data['arp'],
      :arp_timeout          => data['arp-timeout'],
      :slaves               => data['slaves'].split(','),
      :mode                 => data['mode'],
      :link_monitoring      => data['link-monitoring'],
      :transmit_hash_policy => data['transmit-hash-policy'],
      :primary              => data['primary']
    )
  end

  def flush
    Puppet.debug("Flushing Bonded Interface #{resource[:name]}")
      
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
    params["slaves"] = resource[:slaves].join(',') if ! resource[:slaves].nil?
    params["mode"] = resource[:mode] if ! resource[:mode].nil?
    params["link-monitoring"] = resource[:link_monitoring] if ! resource[:link_monitoring].nil?
    params["transmit-hash-policy"] = resource[:transmit_hash_policy] if ! resource[:transmit_hash_policy].nil?
    params["primary"] = resource[:primary] if ! resource[:primary].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bonding", params, lookup)
  end  
end
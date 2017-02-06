require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_ethernet).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/ethernet")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
      new(
        :ensure           => :present,
        :name             => data['default-name'],
        :alias            => data['name'],
        :mtu              => data['mtu'],
        :arp              => data['arp'],
        :arp_timeout      => data['arp_timeout'],
        :auto_negotiation => data['auto_negotiation'],
        :advertise        => data['advertise'].split(',')
      )
  end

  def flush
    Puppet.debug("Flushing Ethernet Interface #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:alias] if ! resource[:alias].nil?
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["arp"] = resource[:arp] if ! resource[:arp].nil?
    params["arp-timeout"] = resource[:arp_timeout] if ! resource[:arp_timeout].nil?
    params["auto-negotiation"] = resource[:auto_negotiation] if ! resource[:auto_negotiation].nil?
    params["advertise"] = resource[:advertise].join(',') if ! resource[:advertise].nil?

    lookup = {}
    lookup["default-name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/ethernet", params, lookup)
  end  
end
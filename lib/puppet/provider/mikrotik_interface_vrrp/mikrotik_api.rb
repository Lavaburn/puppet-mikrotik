require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_interface_vrrp).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/vrrp")
    instances = interfaces.collect { |interface| interface(interface) }    
    instances
  end
  
  def self.interface(data)
      new(
        :ensure          => :present,
        :name            => data['name'],
        :mtu             => data['mtu'],
        :arp             => data['arp'],
        :arp_timeout     => data['arp-timeout'],
        :interface       => data['interface'],
        :vrid            => data['vrid'],
        :priority        => data['priority'],
        :interval        => data['interval'],
        :preemption_mode => data['preemption-mode'],
        :authentication  => data['authentication'],
        :password        => data['password'],
        :version         => data['version'],
        :v3_protocol     => data['v3-protocol'],
        :on_master       => data['on-master'],
        :on_backup       => data['on-backup']
      )
  end

  def flush
    Puppet.debug("Flushing VRRP Interface #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["mtu"] = resource[:mtu] if ! resource[:mtu].nil?
    params["arp"] = resource[:arp] if ! resource[:arp].nil?
    params["arp-timeout"] = resource[:arp_timeout] if ! resource[:arp_timeout].nil?
    params["interface"] = resource[:interface] if ! resource[:interface].nil?
    params["vrid"] = resource[:vrid] if ! resource[:vrid].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["interval"] = resource[:interval] if ! resource[:interval].nil?
    params["preemption-mode"] = resource[:preemption_mode] if ! resource[:preemption_mode].nil?      
    params["authentication"] = resource[:authentication] if ! resource[:authentication].nil?
    params["password"] = resource[:password] if ! resource[:password].nil?
    params["version"] = resource[:version] if ! resource[:version].nil?
    params["v3-protocol"] = resource[:v3_protocol] if ! resource[:v3_protocol].nil?
    params["on-master"] = resource[:on_master] if ! resource[:on_master].nil?
    params["on-backup"] = resource[:on_backup] if ! resource[:on_backup].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/vrrp", params, lookup)
  end  
end
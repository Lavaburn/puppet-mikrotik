require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik  
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances
    interfaces = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge")
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
      :ensure            => :present,
      :state             => state,
      :name              => data['name'],
      :mtu               => data['mtu'],
      :arp               => data['arp'],
      :arp_timeout       => data['arp-timeout'],
      :admin_mac         => data['admin-mac'],
      :igmp_snooping     => (data['igmp-snooping'].nil? ? :false : data['igmp-snooping']),
      :dhcp_snooping     => (data['dhcp-snooping'].nil? ? :false : data['dhcp-snooping']),
      :fast_forward      => (data['fast-forward'].nil? ? :false : data['fast-forward']),
      :protocol_mode     => data['protocol-mode'],
      :priority          => data['priority'],
      :region_name       => data['region-name'],
      :region_revision   => data['region-revision'],
      :vlan_filtering    => (data['vlan-filtering'].nil? ? :false : data['vlan-filtering']),
      :pvid              => data['pvid'],
      :ether_type        => data['ether-type'],
      :frame_types       => data['frame-types'],
      :ingress_filtering => (data['ingress-filtering'].nil? ? :false : data['ingress-filtering']),
      :comment           => data['comment']
    )
  end

  def flush
    Puppet.debug("Flushing Bridge #{resource[:name]}")
      
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
    params["admin-mac"] = resource[:admin_mac] if ! resource[:admin_mac].nil?    
    # Required for newer versions of v6 (>=v6.45 ??)
    if resource[:admin_mac].nil?
      params["auto-mac"] = 'yes'
    else
      params["auto-mac"] = 'no'
    end
    params["igmp-snooping"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:igmp_snooping]) if ! resource[:igmp_snooping].nil?
    params["dhcp-snooping"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:dhcp_snooping]) if ! resource[:dhcp_snooping].nil?
    params["fast-forward"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:fast_forward]) if ! resource[:fast_forward].nil?
    params["protocol-mode"] = resource[:protocol_mode] if ! resource[:protocol_mode].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["region-name"] = resource[:region_name] if ! resource[:region_name].nil?      
    params["region-revision"] = resource[:region_revision] if ! resource[:region_revision].nil?
    params["vlan-filtering"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:vlan_filtering]) if ! resource[:vlan_filtering].nil?
    params["pvid"] = resource[:pvid] if ! resource[:pvid].nil?      
    params["ether-type"] = resource[:ether_type] if ! resource[:ether_type].nil?
    params["frame-types"] = resource[:frame_types] if ! resource[:frame_types].nil?
    params["ingress-filtering"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:ingress_filtering]) if ! resource[:ingress_filtering].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/interface/bridge", params, lookup)
  end  
end
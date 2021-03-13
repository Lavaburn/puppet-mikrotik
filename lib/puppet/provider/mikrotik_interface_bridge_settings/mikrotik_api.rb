require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_bridge_settings).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    bridge_settings = Puppet::Provider::Mikrotik_Api::get_all("/interface/bridge/settings")
    bridge_settings.each do |data|
      object = bridgeSettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.bridgeSettings(data)
    Puppet.debug("Bridge Settings: #{data}")  # TODO: REMOVE !
    
    new(
      :name                      => 'bridge',
      :allow_fast_path           => data['allow-fast-path'],
      :use_ip_firewall           => data['use-ip-firewall'],
      :use_ip_firewall_for_pppoe => data['use-ip-firewall-for-pppoe'],
      :use_ip_firewall_for_vlan  => data['use-ip-firewall-for-vlan']
    )
  end

  def flush
    Puppet.debug("Flushing Bridge Settings")
    
    if (@property_hash[:name] != 'bridge') 
      raise "There is only one set of Bridge settings. Title (name) should be -bridge-"
    end
    
    update = {}
    update["allow-fast-path"] = resource[:allow_fast_path] if ! resource[:allow_fast_path].nil?
    update["use-ip-firewall"] = resource[:use_ip_firewall] if ! resource[:use_ip_firewall].nil?
    update["use-ip-firewall-for-pppoe"] = resource[:use_ip_firewall_for_pppoe] if ! resource[:use_ip_firewall_for_pppoe].nil?
    update["use-ip-firewall-for-vlan"] = resource[:use_ip_firewall_for_vlan] if ! resource[:use_ip_firewall_for_vlan].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/interface/bridge/settings", update)
  end
end
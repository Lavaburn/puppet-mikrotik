require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_system).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances
    system_identity_name = ""
    system_clock_timzeone = ""
    ntp_client_data = []
    
    identity = Puppet::Provider::Mikrotik_Api::get_all("/system/identity")
    identity.each do |data|
      system_identity_name = data['name']
    end

    clock = Puppet::Provider::Mikrotik_Api::get_all("/system/clock")
    clock.each do |data|
      system_clock_timzeone = data['time-zone-name']
    end

    ntp_client = Puppet::Provider::Mikrotik_Api::get_all("/system/ntp/client")
    ntp_client.each do |data|
      ntp_client_data = data
    end
    
    system = new(
      :name          => 'system',
      :identity      => system_identity_name,
      :timezone      => system_clock_timzeone,
      :ntp_enabled   => ntp_client_data['enabled'],
      :ntp_primary   => ntp_client_data['primary-ntp'],
      :ntp_secondary => ntp_client_data['secondary-ntp']
    )
    instances = [system]
    
    instances
  end
  
  def flush
    Puppet.debug("Flushing System Settings")
    
    if (@property_hash[:name] != 'system') 
      raise "There is only one set of System settings. Title (name) should be -system-"
    end
    
    identity = {}
    identity["name"] = resource[:identity] if ! resource[:identity].nil?
    result = Puppet::Provider::Mikrotik_Api::set("/system/identity", identity)

    clock = {}
    clock["time-zone-name"] = resource[:timezone] if ! resource[:timezone].nil?
    result = Puppet::Provider::Mikrotik_Api::set("/system/clock", clock)
    
    ntp_client = {}
    ntp_client["enabled"] = resource[:ntp_enabled] if ! resource[:ntp_enabled].nil?
    ntp_client["primary-ntp"] = resource[:ntp_primary] if ! resource[:ntp_primary].nil?
    ntp_client["secondary-ntp"] = resource[:ntp_secondary] if ! resource[:ntp_secondary].nil?

    result = Puppet::Provider::Mikrotik_Api::set("/system/ntp/client", ntp_client)
  end
end

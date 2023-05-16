require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_system).provide(:mikrotik_api_v7, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v7
  
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

    ntp_servers_data = []
    ntp_servers = Puppet::Provider::Mikrotik_Api::get_all("/system/ntp/client/servers")
    ntp_servers.each do |data|
      if data['dynamic'] == "false"
        Puppet.info("NTP SVR: #{data.inspect}")
        ntp_servers_data.push(data['address'])
      end
    end
    
    system = new(
      :name          => 'system',
      :identity      => system_identity_name,
      :timezone      => system_clock_timzeone,
      :ntp_enabled   => ntp_client_data['enabled'],
      :ntp_primary   => ntp_servers_data[0],
      :ntp_secondary => ntp_servers_data[1]
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

    result = Puppet::Provider::Mikrotik_Api::set("/system/ntp/client", ntp_client)
    
    # This is a very bad fix. Should be it's own resource... 
    # This is only added for backwards-compatibility.

    id_list = Puppet::Provider::Mikrotik_Api::lookup_id("/system/ntp/client/servers", { "dynamic" => false })
    id_list.each do |id|
      id_lookup = { ".id" => id } 
      result = Puppet::Provider::Mikrotik_Api::remove("/system/ntp/client/servers", id_lookup)
    end      

    result = Puppet::Provider::Mikrotik_Api::add("/system/ntp/client/servers", { "address" => resource[:ntp_primary] }) if ! resource[:ntp_primary].nil?
    result = Puppet::Provider::Mikrotik_Api::add("/system/ntp/client/servers", { "address" => resource[:ntp_secondary] }) if ! resource[:ntp_secondary].nil?
  end
end

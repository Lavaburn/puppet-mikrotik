require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_neighbor_discovery_settings).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    data = Puppet::Provider::Mikrotik_Api::get_all("/ip/neighbor/discovery-settings")
    data.collect { |d| neighborDiscoverySettings(d) }
  end

  def self.neighborDiscoverySettings(data)
    new(
      :ensure                 => :present,
      :name                   => 'neighbor_discovery_settings',
      :discover_interface_list => data['discover-interface-list'],
    )
  end

  def flush
    if @property_hash[:name] != 'neighbor_discovery_settings'
      raise "There is only one neighbor discovery settings resource. Title (name) should be -neighbor_discovery_settings-"
    end

    update = {}
    update["discover-interface-list"] = resource[:discover_interface_list] if !resource[:discover_interface_list].nil?

    Puppet::Provider::Mikrotik_Api::set("/ip/neighbor/discovery-settings", update)
  end
end

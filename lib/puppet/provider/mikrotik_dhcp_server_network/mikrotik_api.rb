require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_dhcp_server_network).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    networks = Puppet::Provider::Mikrotik_Api::get_all("/ip/dhcp-server/network")
    networks.each do |network|
      object = dhcpServerNetwork(network)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.dhcpServerNetwork(data)
    new(
      :ensure           => :present,
      :name             => data['address'],
      :gateways         => data['gateway'].nil? ? nil : data['gateway'].split(','),
      :netmask          => data['netmask'],
      :dns_servers      => data['dns-server'].nil? ? nil : data['dns-server'].split(','),
      :domain           => data['domain'],
      :wins_servers     => data['wins-server'].nil? ? nil : data['wins-server'].split(','),
      :ntp_servers      => data['ntp-server'].nil? ? nil : data['ntp-server'].split(','),
      :caps_managers    => data['caps-manager'].nil? ? nil : data['caps-manager'].split(','),
      :next_server      => data['next-server'],
      :boot_file_name   => data['boot-file-name'],
      :dhcp_options     => data['dhcp-option'].nil? ? nil : data['dhcp-option'].split(','),
      :dhcp_option_sets => data['dhcp-option-set'].nil? ? nil : data['dhcp-option-set'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing DHCP Server Network #{resource[:name]}")
      
    params = {}
    params["address"] = resource[:name]
    params["gateway"] = resource[:gateways].join(',') if !resource[:gateways].nil?
    params["netmask"] = resource[:netmask] if !resource[:netmask].nil?
    params["dns-server"] = resource[:dns_servers].join(',') if !resource[:dns_servers].nil?
    params["domain"] = resource[:domain] if !resource[:domain].nil?
    params["wins-server"] = resource[:wins_servers].join(',') if !resource[:wins_servers].nil?
    params["ntp-server"] = resource[:ntp_servers].join(',') if !resource[:ntp_servers].nil?
    params["caps-manager"] = resource[:caps_managers].join(',') if !resource[:caps_managers].nil?
    params["next-server"] = resource[:next_server] if !resource[:next_server].nil?
    params["boot-file-name"] = resource[:boot_file_name] if !resource[:boot_file_name].nil?
    params["dhcp-option"] = resource[:dhcp_options].join(',') if !resource[:dhcp_options].nil?
    params["dhcp-option-set"] = resource[:dhcp_option_sets].join(',') if !resource[:dhcp_option_sets].nil?

    lookup = {}
    lookup["address"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/dhcp-server/network", params, lookup)
  end  
end

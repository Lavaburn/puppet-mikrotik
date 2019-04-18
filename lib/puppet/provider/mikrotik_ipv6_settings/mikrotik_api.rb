require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ipv6_settings).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    ip_settings = Puppet::Provider::Mikrotik_Api::get_all("/ipv6/settings")
    ip_settings.each do |data|
      object = ipSettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.ipSettings(data)
    new(
      :name                         => 'ipv6',
      :forward                      => data['forward'],
      :accept_redirects             => (data['accept-redirects'] == "yes-if-forwarding-disabled"?'true':'false'),# TODO: verify string boolean ?
      :accept_router_advertisements => data['accept-router-advertisements'],
      :max_neighbor_entries         => data['max-neighbor-entries']
    )
  end

  def flush
    Puppet.debug("Flushing IPv6 Settings")
    
    if (@property_hash[:name] != 'ipv6') 
      raise "There is only one set of IP settings. Title (name) should be -ipv6-"
    end
    
    update = {}
    update["forward"] = resource[:forward] if ! resource[:forward].nil?
    if !resource[:accept_redirects].nil? 
      if resource[:accept_redirects] == :true    # TODO: verify types (string/bool)
        update["accept-redirects"] = "yes-if-forwarding-disabled"
      else
        update["accept-redirects"] = "no"
      end
    end
    update["accept-router-advertisements"] = resource[:accept_router_advertisements] if ! resource[:accept_router_advertisements].nil?
    update["max-neighbor-entries"] = resource[:max_neighbor_entries] if ! resource[:max_neighbor_entries].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/ipv6/settings", update)
  end
end

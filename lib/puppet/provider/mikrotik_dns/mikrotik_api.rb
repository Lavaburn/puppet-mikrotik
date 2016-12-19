require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_dns).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    dns = Puppet::Provider::Mikrotik_Api::get_all("/ip/dns")
    dns.each do |data|
      object = dnsSettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.dnsSettings(data)
    new(
      :name                  => 'dns',
      :servers               => data['servers'].split(','),
      :allow_remote_requests => (data['allow-remote-requests'] == 'true')
    )
  end

  def flush
    Puppet.debug("Flushing DNS")
    
    if (@property_hash[:name] != 'dns') 
      raise "There is only one set of DNS settings. Title (name) should be -dns-"
    end
    
    update = {}
    update["servers"] = @property_hash[:servers].join(",")
    update["allow-remote-requests"] = @property_hash[:allow_remote_requests].to_s
    
    result = Puppet::Provider::Mikrotik_Api::set("/ip/dns", update)
  end
end
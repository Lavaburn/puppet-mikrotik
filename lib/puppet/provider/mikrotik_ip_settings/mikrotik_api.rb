require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_settings).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    ip_settings = Puppet::Provider::Mikrotik_Api::get_all("/ip/settings")
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
      :name      => 'ip',
      :rp_filter => data['rp-filter']
    )
  end

  def flush
    Puppet.debug("Flushing IP Settings")
    
    if (@property_hash[:name] != 'ip') 
      raise "There is only one set of IP settings. Title (name) should be -ip-"
    end
    
    update = {}
    update["rp-filter"] = resource[:rp_filter] if ! resource[:rp_filter].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/ip/settings", update)
  end
end
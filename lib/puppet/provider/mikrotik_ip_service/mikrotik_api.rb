require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_service).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
    
    services = get_all("/ip/service")
    # ROS 7.19+: skip dynamic per-connection entries
    services = services.reject { |service| service['dynamic'] == 'true' || service['connection'] == 'true' }
    instances = services.collect { |service| ipService(service) }
    
    instances
  end
  
  def self.ipService(service)
    #Puppet.debug("IP Service: #{service.inspect}")
    
    if service['disabled'] == 'true'
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure    => :present,
      :state     => state,
      :name      => service['name'],
      :port      => service['port'],
      :addresses => service['address'].to_s.split(',')
    )
  end

  def flush
    Puppet.debug("Flushing IP Service #{resource[:name]}")
    
    path = '/ip/service'
    
    params = {}
        
    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end
    
    params["port"] = resource[:port] if ! resource[:port].nil?   
    if ! resource[:addresses].nil?
      params["address"] = resource[:addresses].join(',')
    end
             
    # ROS 7.19+: /ip/service carries a dynamic row per live connection - our own
    # API session shows up as `api`; set on it => "this is configured elsewhere".
    services = self.class.get_all(path).select { |service|
      service['name'] == resource[:name] && service['dynamic'] != 'true' && service['connection'] != 'true'
    }
    services.each do |service|
      result = Puppet::Provider::Mikrotik_Api::set(path, params.merge({ ".id" => service['.id'] }))
    end
  end  
end
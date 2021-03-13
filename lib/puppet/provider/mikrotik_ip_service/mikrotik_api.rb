require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_service).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
    
    services = get_all("/ip/service")
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
      :addresses => service['address'].split(',')
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
             
    lookup = { "name" => resource[:name] }
    
    id_list = Puppet::Provider::Mikrotik_Api::lookup_id(path, lookup)
    id_list.each do |id|
      params = params.merge({ ".id" => id })
      result = Puppet::Provider::Mikrotik_Api::set(path, params)
    end
  end  
end
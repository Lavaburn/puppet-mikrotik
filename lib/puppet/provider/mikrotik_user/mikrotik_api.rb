require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_user).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances    
    users = Puppet::Provider::Mikrotik_Api::get_all("/user")
    instances = users.collect { |user| userObject(user) }    
    instances
  end
  
  def self.userObject(data)
    addresses = data['address'].nil? ? nil : data['address'].split(',')

    if data['disabled'] == 'true'
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure    => :present,
      :state     => state,
      :name      => data['name'],
      :group     => data['group'],
      :addresses => addresses
    )
  end

  def flush
    Puppet.debug("Flushing User #{resource[:name]}")
      
    params = {}
        
    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end
    
    params["name"] = resource[:name]
    params["group"] = resource[:group] if ! resource[:group].nil?
    params["address"] = resource[:addresses].join(',') if ! resource[:addresses].nil?
    params["password"] = resource[:password] if ! resource[:password].nil?
      
    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/user", params, lookup)
  end  
end

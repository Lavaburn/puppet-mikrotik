require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_upgrade_source).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    sources = Puppet::Provider::Mikrotik_Api::get_all("/system/upgrade/upgrade-package-source")
    #Puppet.debug("/system/upgrade/upgrade-package-source: #{sources.inspect}")
    instances = sources.collect { |source| upgradeSource(source) }
    
    instances
  end
  
  def self.upgradeSource(source)    
    new(
      :ensure   => :present,
      :name     => source['address'],
      :username => source['user']
    )
  end

  def flush
    #Puppet.debug("Flushing Upgrade Source #{resource[:name]}")
      
    params = {}
    params["address"] = resource[:name]
    params["user"] = resource[:username] if ! resource[:username].nil?

    # Password can not be managed once created !
    if @property_flush[:ensure] == :present
      params["password"] = resource[:password] if ! resource[:password].nil?
    end
    
    lookup = {}
    lookup["address"] = resource[:name]
    
    #Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/system/upgrade/upgrade-package-source", params, lookup)
  end  
end
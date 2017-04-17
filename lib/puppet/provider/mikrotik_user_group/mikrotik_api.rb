require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_user_group).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    user_groups = Puppet::Provider::Mikrotik_Api::get_all("/user/group")
    instances = user_groups.collect { |user_group| userGroup(user_group) }    
    instances
  end
  
  def self.userGroup(data)
    fullpolicy = data['policy'].split(',')
    policy = fullpolicy.delete_if { |permission| permission.start_with?('!') }
    
    new(
      :ensure => :present,
      :name   => data['name'],
      :skin   => data['skin'],
      :policy => policy
    )
  end

  def flush
    Puppet.debug("Flushing User Group #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["skin"] = resource[:skin] if ! resource[:skin].nil?
    params["policy"] = resource[:policy].join(',') if ! resource[:policy].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/user/group", params, lookup)
  end  
end
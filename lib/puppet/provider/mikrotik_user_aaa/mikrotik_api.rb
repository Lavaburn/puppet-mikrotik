require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_user_aaa).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    aaa = Puppet::Provider::Mikrotik_Api::get_all("/user/aaa")
    aaa.each do |data|
      object = userAAASettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.userAAASettings(data)        
    new(
      :name           => 'aaa',
      :use_radius     => data['use-radius'],
      :accounting     => data['accounting'],
      :interim_update => data['interim-update'],
      :default_group  => data['default-group'],
      :exclude_groups => data['exclude-groups'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing User AAA")
    
    if (@property_hash[:name] != 'aaa') 
      raise "There is only one set of User AAA settings. Title (name) should be -aaa-"
    end
    
    update = {}
    update["use-radius"]     = (resource[:use_radius].to_s) if ! resource[:use_radius].nil?
    update["accounting"]     = (resource[:accounting].to_s) if ! resource[:accounting].nil?
    update["interim-update"] = resource[:interim_update] if ! resource[:interim_update].nil?
    update["default-group"]  = resource[:default_group] if ! resource[:default_group].nil?
    update["exclude-groups"] = resource[:exclude_groups].join(",") if ! resource[:exclude_groups].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/user/aaa", update)
  end
end

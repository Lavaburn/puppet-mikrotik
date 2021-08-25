require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_interface_list).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    interface_members = {}
    
    members = get_all("/interface/list/member")
    members.each do |member|
      list_name = member["list"]
      unless interface_members.key?(list_name)
        interface_members[list_name] = []
      end
      interface_members[list_name] << member["interface"]
    end
    
    lists = Puppet::Provider::Mikrotik_Api::get_all("/interface/list")
    instances = lists.collect do |list| 
      list_name = list['name']
      interface_members[list_name] = [] unless interface_members.key?(list_name)

      interface_list(list_name, interface_members[list_name],list)
    end
    
    instances
  end
  
  def self.interface_list(name, members,details)
    new(
      :ensure  => :present,
      :name    => name,
      :members => members,
      :include => details['include'].split(','),
      :exclude => details['exclude'].split(',')
    )
  end
  
  def flush
    Puppet.debug("Flushing Interface List #{resource[:name]}")    
      
    list_params = {}
    list_params["name"] = resource[:name]
    list_params["include"] = resource[:include].join(',') if !resource[:include].nil?
    list_params["exclude"] = resource[:exclude].join(',') if !resource[:exclude].nil?

    members_params = {}
    members_params["list"] = resource[:name]
    
    list_flush("/interface/list", list_params, :members, "/interface/list/member", members_params, :interface)
  end
  
  def list_flush(list_path, list_params, members_param_name, members_path, members_params, member_param_name)  
    Puppet.debug("list_flush(#{list_path}, #{list_params.inspect}, #{members_param_name}, #{members_path}, #{members_params.inspect}, #{member_param_name})")

    # CREATE
    if @property_flush[:ensure] == :present
      Puppet.debug("Creating #{list_path}")
  
      # create list
      result = Puppet::Provider::Mikrotik_Api::add(list_path, list_params)
      
      # create members
      if resource[:manage_members]
        resource[members_param_name].each do |item|
          Puppet.debug("Create member #{item} in #{members_path}")
      
          params2 = members_params.merge({member_param_name => item})
          result = Puppet::Provider::Mikrotik_Api::add(members_path, params2)
        end
      end
    end
  
    # DESTROY
    if @property_flush[:ensure] == :absent
      Puppet.debug("Deleting #{list_path}")

      # remove members (and save the orphans)
      # TODO: deleting an interface also creates an orphan      
      id_list = Puppet::Provider::Mikrotik_Api::lookup_id(members_path, members_params)
      id_list.each do |id|
        id_lookup = { ".id" => id } 
        result = Puppet::Provider::Mikrotik_Api::remove(members_path, id_lookup)
      end
      
      # remove list
      id_list = Puppet::Provider::Mikrotik_Api::lookup_id(list_path, list_params)
      id_list.each do |id|
        id_lookup = { ".id" => id } 
        result = Puppet::Provider::Mikrotik_Api::remove(list_path, id_lookup)
      end
    end
    
    # UPDATE
    if @property_flush.empty?
      Puppet.debug("Updating #{members_path}")
      
      if resource[:manage_members]
        # Create members
        (@property_hash[members_param_name] - @original_values[members_param_name]).each do |item|
          Puppet.debug("Create member #{item} in #{members_path}")
      
          params2 = members_params.merge({member_param_name => item})
          result = Puppet::Provider::Mikrotik_Api::add(members_path, params2)
        end
        
        # Delete members
        (@original_values[members_param_name] - @property_hash[members_param_name]).each do |item|
          Puppet.debug("Delete member #{item} in #{members_path}")

          lookup2 = members_params.merge({member_param_name => item})
          id_list = Puppet::Provider::Mikrotik_Api::lookup_id(members_path, lookup2)
          id_list.each do |id|
            id_lookup = { ".id" => id } 
            result = Puppet::Provider::Mikrotik_Api::remove(members_path, id_lookup)        
          end
        end
      end
    end    
  end 
end
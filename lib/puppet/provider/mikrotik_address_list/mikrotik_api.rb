require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_address_list).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
    
    sorted_addresses = {}
    address_list_entries = get_all("/ip/firewall/address-list")
    address_list_entries.each do |entry|
      list = entry["list"]
      address = entry["address"]
      
      if !sorted_addresses.key?(list)
        sorted_addresses[list] = []
      end
      
      sorted_addresses[list].push(address)      
    end
    
    sorted_addresses.each do |list, addresses|
      instances << addressList(list, addresses)
    end
    
    instances
  end
  
  def self.addressList(list, addresses)
      new(
        :ensure    => :present,
        :name      => list,
        :addresses => addresses
      )
  end

  def flush
    Puppet.debug("Flushing Address List #{resource[:name]}")
      
    params = {}
    params["list"] = resource[:name]
    
    #Puppet.debug("Params (= Lookup): #{params.inspect}")
   
    list_flush("/ip/firewall/address-list", params, params, :addresses,  "address")
  end
  
  def list_flush(path, params, lookup, list_name, entry_name)  
    Puppet.debug("list_flush(#{path}, #{params.inspect}, #{lookup.inspect}, #{list_name.inspect}, #{entry_name.inspect})")
    
    # create
    if @property_flush[:ensure] == :present
      Puppet.debug("Creating #{path}")
      
      resource[list_name].each do |entry|
        params2 = params.merge({entry_name => entry})
        result = Puppet::Provider::Mikrotik_Api::add(path, params2)
      end
    end
  
    # destroy
    if @property_flush[:ensure] == :absent
      Puppet.debug("Deleting #{path}")
      
      id_list = Puppet::Provider::Mikrotik_Api::lookup_id(path, lookup)
      id_list.each do |id|
        id_lookup = { ".id" => id } 
        result = Puppet::Provider::Mikrotik_Api::remove(path, id_lookup)
      end      
    end      
    
    # update
    if @property_flush.empty?
      Puppet.debug("Updating #{path}")
      
      # Create
      (@property_hash[list_name] - @original_values[list_name]).each do |item|
        params2 = params.merge({entry_name => item})
        result = Puppet::Provider::Mikrotik_Api::add(path, params2)
      end
      
      # Delete
      (@original_values[list_name] - @property_hash[list_name]).each do |item|
        lookup2 = lookup.merge({entry_name => item})
        id_list = Puppet::Provider::Mikrotik_Api::lookup_id(path, lookup2)
        id_list.each do |id|
          id_lookup = { ".id" => id } 
          result = Puppet::Provider::Mikrotik_Api::remove(path, id_lookup)        
        end
      end
    end    
  end
end
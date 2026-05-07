require_relative '../util/network_device/mikrotik'
require_relative '../util/network_device/transport/mikrotik'

class Puppet::Provider::Mikrotik_Api < Puppet::Provider
  # Primary cache-clearing happens in Device#initialize (_reset_version_caches)
  # before Puppet assigns providers to resources.  This override is a secondary
  # defence: if suitable? is reached with a stale transport ID (e.g. the device
  # was initialised via a code path that skips Device#initialize), it performs
  # the same clearing so the feature cache and @defaultprovider are always fresh.
  def self.suitable?
    current_transport_id = Puppet::Util::NetworkDevice.current&.transport&.object_id
    base = Puppet::Provider::Mikrotik_Api
    if current_transport_id && current_transport_id != base.instance_variable_get(:@_last_transport_id)
      base.instance_variable_set(:@_last_transport_id, current_transport_id)
      if (vals = Puppet.features.instance_variable_get(:@results))
        [:ros_v6, :ros_v7, :ros_v7_12, :ros_v7_pre12].each { |f| vals.delete(f) }
      end
      Puppet::Type.eachtype do |type|
        next unless type
        dp = type.instance_variable_get(:@defaultprovider)
        type.instance_variable_set(:@defaultprovider, nil) if dp && dp <= base
      end
    end
    super
  end

  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.transport
    if Puppet::Util::NetworkDevice.current
      # we are in `puppet device`
      Puppet::Util::NetworkDevice.current.transport
    else
      # we are in `puppet resource`
      Puppet::Util::NetworkDevice::Transport::Mikrotik.new(Facter.value(:url))
    end
  end

  def self.connection
    transport.connection
  end
  
  def self.get_all(path)
    Puppet.debug("Retrieving Config #{path}")
    
    objects = connection.get_reply("#{path}/getall")
    
    result = []
    objects.each do |object| 
      #Puppet.debug("Object: #{object}")        
      
      if object.key?('!re')
        result << object.reject { |k, v| ['!re', '.tag'].include? k  }
      end
    end
    result
  end

  def self.set(path, params_hash)
    Puppet.debug("Storing Config #{path}: #{params_hash.inspect}")
    
    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    #Puppet.debug("Params: #{params.inspect}")
    
    result = connection.get_reply("#{path}/set", *params)    # .id => ?.id ???
    Puppet.debug("Set Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while setting #{path}: #{res['message']}"
      end
    end
  end
  
  def self.add(path, params_hash)
    Puppet.debug("Creating Config #{path}: #{params_hash.inspect}")
    
    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    #Puppet.debug("Params: #{params}")
    
    result = connection.get_reply("#{path}/add", *params)    
    Puppet.debug("Add Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while adding #{path}: #{res['message']}"
      end
    end
  end

  def self.remove(path, params_hash)
    Puppet.debug("Removing Config #{path}: #{params_hash.inspect}")
    
    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    
    result = connection.get_reply("#{path}/remove", *params)

    Puppet.debug("Remove Result: #{result}")  
    result.each do |res|
      if res.key?('!trap')
        raise "Error while removing #{path}: #{res['message']}"
      end
    end
  end

  def self.move(path, params_hash)
    Puppet.debug("Moving Config #{path}: #{params_hash.inspect}")
    
    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    
    result = connection.get_reply("#{path}/move", *params)
    Puppet.debug("Move Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while moving #{path}: #{res['message']}"
      end
    end
  end
  
  def self.enable(path, params_hash)
    Puppet.debug("Enabling #{path}: #{params_hash.inspect}")

    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    #Puppet.debug("Params: #{params.inspect}")
    
    result = connection.get_reply("#{path}/enable", *params)    # .id => ?.id ???
    Puppet.debug("Set Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while setting #{path}: #{res['message']}"
      end
    end
  end

  def self.disable(path, params_hash)
    Puppet.debug("Disabling #{path}: #{params_hash.inspect}")

    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
    #Puppet.debug("Params: #{params.inspect}")
    
    result = connection.get_reply("#{path}/disable", *params)    # .id => ?.id ???
    Puppet.debug("Set Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while setting #{path}: #{res['message']}"
      end
    end
  end

  def self.command(path, params_hash = {})
    Puppet.debug("Running Command: #{path}: #{params_hash.inspect}")

    params = []
    params << params_hash.collect { |k,v| "=#{k}=#{v}" }
      
    result = connection.get_reply(path, *params)
    Puppet.debug("Command Result: #{result}")
    result.each do |res|
      if res.key?('!trap')
        raise "Error while running command #{path}: #{res['message']}"
      end
    end
  end
  
  def initialize(value = {})
    super(value)
    
    if value.is_a? Hash
      @original_values = value.clone
    else
      @original_values = {}
    end
    
    @property_flush = {}
  end
  
  def exists?
    [:present, :enabled, :disabled].include?(@property_hash[:ensure]) 
  end
  
  def create
    @property_flush[:ensure] = :present
  end
  
  def destroy        
    @property_flush[:ensure] = :absent
  end
  
  def simple_flush(path, params, lookup)  
    #Puppet.debug("simple_flush(#{path}, #{params.inspect}, #{lookup.inspect})")
    
    # create
    if @property_flush[:ensure] == :present and @original_values.empty?
      Puppet.debug("Creating #{path}")
      
      result = Puppet::Provider::Mikrotik_Api::add(path, params)
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
    if ! @original_values.empty?
      Puppet.debug("Updating #{path}")
        
      id_list = Puppet::Provider::Mikrotik_Api::lookup_id(path, lookup)
      id_list.each do |id|
        params = params.merge({ ".id" => id })
        result = Puppet::Provider::Mikrotik_Api::set(path, params)
      end
    end    
  end
  
  def self.lookup_id(path, lookup)
    id_list = []
      
    query_words = lookup.collect { |k,v| "?#{k}=#{v}" }
    
    objects = connection.get_reply("#{path}/getall", *query_words)      
    objects.each do |object| 
      if object.key?('!re')
        id_list << object[".id"]
      end
    end      
    #Puppet.debug("ID list for #{path} with #{lookup.inspect}: #{id_list.inspect}")
      
    id_list
  end
  
  # Different ensure options can be stored in "state"
  def setState(state)
    @property_hash[:state] = state
  end  
  
  def getState
    return :absent if @property_hash[:state].nil?
    
    @property_hash[:state]
  end  
  
  def self.convertStringToBool(str)
    result = str == 'true'?true:false
    result
  end
  
  def self.convertBoolToYesNo(str)
    result = str.to_s == 'true' ? "yes" : "no"
    result
  end
  
  def self.convertYesNoToBool(str)
    result = str == 'yes'?true:false
    result
  end
end
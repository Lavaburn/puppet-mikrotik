require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_logging_action).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances      
    actions = get_all("/system/logging/action")
    instances = actions.collect { |action| loggingAction(action) }
  end
  
  def self.loggingAction(action)
    new(
      :ensure          => :present,
      :name            => action['name'],
      :target          => action['target'],
      :remote          => action['remote'],
      :remote_port     => action['remote-port'],
      :src_address     => action['src-address'],
      :bsd_syslog      => action['bsd-syslog'],
      :syslog_facility => action['syslog-facility'],
      :syslog_severity => action['syslog-severity']
    )
  end

  def flush
    Puppet.debug("Flushing Logging Action #{resource[:name]}")

    if @property_flush[:ensure] == :present
      if resource[:target].nil?
        raise "Target is a required parameter."
      end
    end

    params = {}
    params["name"] = resource[:name]
    params["target"] = resource[:target]
    if (resource[:target] == :remote)
      params["remote"] = resource[:remote] if ! resource[:remote].nil?
      params["remote-port"] = resource[:remote_port] if ! resource[:remote_port].nil?
      params["src-address"] = resource[:src_address] if ! resource[:src_address].nil?      
      if ! resource[:bsd_syslog].nil?
        params["bsd-syslog"] = resource[:bsd_syslog]?"yes":"no"        
      end
      params["syslog_-facility"] = resource[:syslog_facility] if ! resource[:syslog_facility].nil?
      params["syslog-severity"] = resource[:syslog_severity] if ! resource[:syslog_severity].nil?
    end
    
    lookup = { "name" => resource[:name] }
    
    Puppet.debug("Rule: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/system/logging/action", params, lookup)
  end
end

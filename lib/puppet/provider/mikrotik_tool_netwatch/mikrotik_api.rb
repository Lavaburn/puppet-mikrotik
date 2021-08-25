require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_tool_netwatch).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    watches = Puppet::Provider::Mikrotik_Api::get_all("/tool/netwatch")
    instances = watches.collect { |watch| netwatchCheck(watch) }    
    instances
  end
  
  def self.netwatchCheck(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure      => :present,
      :state       => state,
      :name        => data['host'],
      :interval    => data['interval'],
      :timeout     => data['timeout'],
      :down_script => data['down-script'],
      :up_script   => data['up-script'],
      :comment     => data['comment']        
    )
  end

  def flush
    Puppet.debug("Flushing Netwatch check #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["host"]   = resource[:name]
    params["interval"] = resource[:interval] if ! resource[:interval].nil?
    params["timeout"] = resource[:timeout] if ! resource[:timeout].nil?
    params["down-script"] = resource[:down_script] if ! resource[:down_script].nil?
    params["up-script"] = resource[:up_script] if ! resource[:up_script].nil?
    params["comment"] = resource[:comment] if ! resource[:comment].nil?

    lookup = {}
    lookup["host"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/tool/netwatch", params, lookup)
  end  
end

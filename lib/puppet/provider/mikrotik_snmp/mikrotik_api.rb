require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_snmp).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine feature: :mtik
  
  mk_resource_methods

  def self.instances      
    snmp = Puppet::Provider::Mikrotik_Api::get_all("/snmp")  
    instances = snmp.collect { |data| snmpSettings(data) }
    instances
  end
  
  def self.snmpSettings(data)
    if data['enabled'] == "false"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure          => :present,
      :state           => state,
      :name            => 'snmp',
      :contact         => data['contact'],
      :location        => data['location'],
      :trap_version    => data['trap-version'],
      :trap_community  => data['trap-community'],
      :trap_generators => data['trap-generators'].split(','),
      :trap_targets    => data['trap-target'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing SNMP")
    
    if (@property_hash[:name] != 'snmp') 
      raise "There is only one set of SNMP settings. Title (name) should be -snmp-"
    end

    update = {}
      
    if @property_hash[:state] == :disabled
      update["enabled"] = false
    elsif @property_hash[:state] == :enabled
      update["enabled"] = true
    end 
    
    update["contact"] = resource[:contact] if ! resource[:contact].nil?
    update["location"] = resource[:location] if ! resource[:location].nil?
    update["trap-version"] = resource[:trap_version] if ! resource[:trap_version].nil?
    update["trap-community"] = resource[:trap_community] if ! resource[:trap_community].nil?
    update["trap-generators"] = resource[:trap_generators].join(',') if ! resource[:trap_generators].nil?
    update["trap-target"] = resource[:trap_targets].join(',') if ! resource[:trap_targets].nil?

    result = Puppet::Provider::Mikrotik_Api::set("/snmp", update)
  end
end

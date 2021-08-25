require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_romon).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances      
    romon = Puppet::Provider::Mikrotik_Api::get_all("/tool/romon")  
    instances = romon.collect { |data| romonSettings(data) }
    instances
  end
  
  def self.romonSettings(data)
    if data['enabled'] == "false"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure  => :present,
      :state   => state,
      :name    => 'romon',
      :id      => data['id'],
      :secrets => data['secrets'].split(',')
    )
  end

  def flush
    Puppet.debug("Flushing RoMON")
    
    if (@property_hash[:name] != 'romon') 
      raise "There is only one set of RoMON settings. Title (name) should be -romon-"
    end

    update = {}
      
    if @property_hash[:state] == :disabled
      update["enabled"] = false
    elsif @property_hash[:state] == :enabled
      update["enabled"] = true
    end 
    
    update["id"] = resource[:id] if ! resource[:id].nil?
    update["secrets"] = resource[:secrets].join(',') if ! resource[:secrets].nil?

    result = Puppet::Provider::Mikrotik_Api::set("/tool/romon", update)
  end
end

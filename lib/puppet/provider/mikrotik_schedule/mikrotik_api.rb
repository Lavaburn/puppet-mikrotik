require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_schedule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    schedules = Puppet::Provider::Mikrotik_Api::get_all("/system/scheduler")
    instances = schedules.collect { |schedule| systemSchedule(schedule) }    
    instances
  end
  
  def self.systemSchedule(data)            
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure     => :present,
      :state      => state,
      :name       => data['name'],
      :start_date => data['start-date'],
      :start_time => data['start-time'],
      :interval   => data['interval'],
      :policies   => data['policy'].split(','), 
      :on_event   => data['on-event']
    )
  end

  def flush
    Puppet.debug("Flushing Scheduler #{resource[:name]}")
    
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
      
    params["name"] = resource[:name]
    params["start-date"] = resource[:start_date] if ! resource[:start_date].nil?
    params["start-time"] = resource[:start_time] if ! resource[:start_time].nil?
    params["interval"] = resource[:interval] if ! resource[:interval].nil?      
    params["policy"] = resource[:policies].join(',') if ! resource[:policies].nil?
    params["on-event"] = resource[:on_event] if ! resource[:on_event].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/system/scheduler", params, lookup)
  end  
end

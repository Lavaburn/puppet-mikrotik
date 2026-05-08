require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_traffic_flow).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    data = Puppet::Provider::Mikrotik_Api::get_all("/ip/traffic-flow")
    data.collect { |d| trafficFlowSettings(d) }
  end

  def self.trafficFlowSettings(data)
    state = data['enabled'] == 'true' ? :enabled : :disabled

    new(
      :ensure               => :present,
      :state                => state,
      :name                 => 'traffic_flow',
      :active_flow_timeout  => data['active-flow-timeout'],
      :cache_entries        => data['cache-entries'],
      :interfaces           => data['interfaces'].nil? ? [] : data['interfaces'].split(','),
    )
  end

  def flush
    if @property_hash[:name] != 'traffic_flow'
      raise "There is only one traffic-flow settings resource. Title (name) should be -traffic_flow-"
    end

    update = {}

    if @property_hash[:state] == :disabled
      update["enabled"] = false
    elsif @property_hash[:state] == :enabled
      update["enabled"] = true
    end

    update["active-flow-timeout"] = resource[:active_flow_timeout] if !resource[:active_flow_timeout].nil?
    update["cache-entries"]       = resource[:cache_entries]       if !resource[:cache_entries].nil?
    update["interfaces"]          = resource[:interfaces].join(',') if !resource[:interfaces].nil?

    Puppet::Provider::Mikrotik_Api::set("/ip/traffic-flow", update)
  end
end

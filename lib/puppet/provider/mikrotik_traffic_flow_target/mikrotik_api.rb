require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_traffic_flow_target).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    targets = Puppet::Provider::Mikrotik_Api::get_all("/ip/traffic-flow/target")
    targets.each do |target|
      object = trafficFlowTarget(target)
      instances << object if object
    end

    instances
  end

  def self.trafficFlowTarget(data)
    state = data['disabled'] == 'true' ? :disabled : :enabled

    new(
      :ensure      => :present,
      :state       => state,
      :name        => data['dst-address'],
      :dst_address => data['dst-address'],
      :src_address => data['src-address'],
      :port        => data['port'],
      :version     => data['version'],
    )
  end

  def flush
    Puppet.debug("Flushing traffic-flow target #{resource[:name]}")

    disabled = case @property_hash[:state]
               when :disabled then 'yes'
               when :enabled  then 'no'
               end

    params = {
      "dst-address" => resource[:dst_address] || resource[:name],
      "src-address" => resource[:src_address],
      "port"        => resource[:port],
      "version"     => resource[:version],
      "disabled"    => disabled,
    }.compact

    lookup = { "dst-address" => resource[:dst_address] || resource[:name] }

    simple_flush("/ip/traffic-flow/target", params, lookup)
  end
end

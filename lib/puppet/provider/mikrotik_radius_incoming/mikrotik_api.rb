require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_radius_incoming).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    incoming = Puppet::Provider::Mikrotik_Api::get_all("/radius/incoming")
    incoming.each do |data|
      object = incomingSettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end

  def self.incomingSettings(data)
    new(
      :name   => 'radius_incoming',
      :accept => data['accept'],
      :port   => data['port'],
      :vrf    => data['vrf']
    )
  end

  # ROS v6 has no VRF on /radius incoming: warn and report in sync, so it does not drift every run
  def vrf
    if Puppet.features.ros_v6? && ! resource[:vrf].nil?
      Puppet.warning("RADIUS Incoming - vrf is not supported on ROS v6, ignoring it!")
      return resource[:vrf]
    end
    @property_hash[:vrf]
  end

  def flush
    Puppet.debug("Flushing RADIUS Incoming")

    if (@property_hash[:name] != 'radius_incoming')
      raise "There is only one set of RADIUS Incoming settings. Title (name) should be -radius_incoming-"
    end

    update = {}
    update["accept"] = @property_hash[:accept].to_s if ! @property_hash[:accept].nil?
    update["port"] = @property_hash[:port] if ! @property_hash[:port].nil?
    update["vrf"] = @property_hash[:vrf] if ! @property_hash[:vrf].nil? && ! Puppet.features.ros_v6?

    result = Puppet::Provider::Mikrotik_Api::set("/radius/incoming", update)
  end
end

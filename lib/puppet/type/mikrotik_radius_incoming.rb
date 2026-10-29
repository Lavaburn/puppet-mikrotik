Puppet::Type.newtype(:mikrotik_radius_incoming) do
  apply_to_all

  # Only 1 set of settings that is always enabled. NOT ensurable

  newparam(:name) do
    desc 'Name should be -radius_incoming-'
    isnamevar
  end

  newproperty(:accept) do
    desc 'Whether to accept incoming RADIUS requests (CoA / Disconnect).'
    newvalues(true, false)
  end

  newproperty(:port) do
    desc 'The port to listen on for incoming RADIUS requests (default 3799).'
  end

  newproperty(:vrf) do
    desc 'The VRF to listen on for incoming RADIUS requests (ROS v7 only).'
  end
end

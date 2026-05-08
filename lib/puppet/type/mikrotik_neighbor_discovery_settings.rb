Puppet::Type.newtype(:mikrotik_neighbor_discovery_settings) do
  apply_to_all

  # Singleton — name should always be 'neighbor_discovery_settings'
  newparam(:name) do
    desc 'Name should be -neighbor_discovery_settings-'
    isnamevar
  end

  newproperty(:discover_interface_list) do
    desc 'Interface list used for neighbor discovery (e.g. "all", "!dynamic")'
  end
end

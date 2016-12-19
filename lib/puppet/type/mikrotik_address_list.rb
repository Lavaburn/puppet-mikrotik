Puppet::Type.newtype(:mikrotik_address_list) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The address list name'
    isnamevar
  end

  newproperty(:addresses, :array_matching => :all) do
    desc 'The IP addresses assigned to the list'
  end
end

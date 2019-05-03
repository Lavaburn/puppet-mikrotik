require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_mode_config) do
  apply_to_all
  
  ensurable
  
  newparam(:name) do
    desc 'Mode Config description'
    isnamevar
  end

  newproperty(:address_pool) do
  end

  newproperty(:address_prefix_length) do
  end

  newproperty(:comment) do
  end

  newproperty(:split_include, :array_matching => :all) do
  end

  newproperty(:static_dns) do
  end

  newproperty(:system_dns, boolean: true, parent: Puppet::Property::Boolean) do
  end
end

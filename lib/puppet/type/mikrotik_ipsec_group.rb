require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_group) do
  apply_to_all

  ensurable

  newparam(:name) do
    desc 'Policy template group name'
    isnamevar
    validate do |value|
      if value == 'default'
        raise ArgumentError, "the default IPSec policy template group is managed automatically by RouterOS"
      end
    end
  end
end

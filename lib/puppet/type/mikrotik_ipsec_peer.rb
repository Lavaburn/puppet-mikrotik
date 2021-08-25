require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_peer) do
  apply_to_all

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:enabled) do
      provider.setState(:enabled)
    end

    newvalue(:disabled) do
      provider.setState(:disabled)
    end

    def retrieve
      provider.getState
    end

    def insync?(is)
      @should.each { |should|
        case should
          when :present
            return (provider.getState != :absent)
          when :absent
            return (provider.getState == :absent)
          when :enabled
            return (provider.getState == :enabled)
          when :disabled
            return (provider.getState == :disabled)
        end
      }
    end
  end

  newparam(:name) do
    desc 'Peer description'
    isnamevar
  end

  newproperty(:address) do
    desc 'Address'
  end

  newproperty(:exchange_mode) do
    newvalues(*%w{aggresive base ike2 main})
  end

  newproperty(:local_address) do
  end

  newproperty(:passive, boolean: true, parent: Puppet::Property::Boolean) do
    defaultto true
  end

  newproperty(:port) do
  end

  newproperty(:send_initial_contact, boolean: true, parent: Puppet::Property::Boolean) do
    defaultto false
  end

  newproperty(:profile) do
  end

  newproperty(:comment) do
  end

  autorequire(:mikrotik_ipsec_profile) { self[:profile] }
end

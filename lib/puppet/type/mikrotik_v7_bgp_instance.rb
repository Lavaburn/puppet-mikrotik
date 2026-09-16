Puppet::Type.newtype(:mikrotik_v7_bgp_instance) do
  apply_to_all

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
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
        end
      }
    end
  end

  newparam(:name) do
    desc 'BGP Instance name'
    isnamevar
  end

  newproperty(:as) do
    desc 'The Autonomous System Number (ASN).'
  end

  newproperty(:router_id) do
    desc 'The Router ID (IPv4 address or /routing/id name).'
  end

  newproperty(:vrf) do
    desc 'The VRF this instance runs in.'
  end

  newproperty(:cluster_id) do
    desc 'Route reflector cluster ID.'
  end

  newproperty(:comment) do
    desc 'Extra comments'
  end
end

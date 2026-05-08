Puppet::Type.newtype(:mikrotik_traffic_flow_target) do
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
    desc 'Destination address of the flow target (used as identifier)'
    isnamevar
  end

  newproperty(:dst_address) do
    desc 'Destination IP address of the NetFlow collector'
  end

  newproperty(:src_address) do
    desc 'Source IP address for the exported flows'
  end

  newproperty(:port) do
    desc 'UDP port of the NetFlow collector (default 2055)'
  end

  newproperty(:version) do
    desc 'NetFlow version to use'
    newvalues(1, 5, 9)
  end
end

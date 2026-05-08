Puppet::Type.newtype(:mikrotik_queue_simple) do
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
    desc 'Simple queue name'
    isnamevar
  end

  newproperty(:target) do
    desc 'Target interface or address (e.g. ether1, 192.168.0.0/24)'
  end

  newproperty(:max_limit) do
    desc 'Max download/upload rates as "D/U" (e.g. 12M/12M)'
  end

  newproperty(:limit_at) do
    desc 'Guaranteed download/upload rates as "D/U"'
  end

  newproperty(:queue) do
    desc 'Queue type for download/upload as "D/U" (e.g. ethernet-default/ethernet-default)'
  end

  newproperty(:total_queue) do
    desc 'Total direction queue type name'
  end

  newproperty(:parent) do
    desc 'Parent queue name'
  end

  newproperty(:comment) do
    desc 'Descriptive comment'
  end
end

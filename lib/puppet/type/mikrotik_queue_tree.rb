Puppet::Type.newtype(:mikrotik_queue_tree) do
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
    desc 'Tree queue name'
    isnamevar
  end

  newproperty(:parent) do
    desc 'Parent queue or interface name (e.g. global, ether1)'
  end

  newproperty(:packet_mark) do
    desc 'Mangle packet mark to match'
  end

  newproperty(:queue) do
    desc 'Queue type name to use for this entry'
  end

  newproperty(:max_limit) do
    desc 'Maximum rate (e.g. 10M)'
  end

  newproperty(:limit_at) do
    desc 'Guaranteed rate (e.g. 3072k)'
  end

  newproperty(:priority) do
    desc 'Queue priority (1-8)'
  end

  newproperty(:comment) do
    desc 'Descriptive comment'
  end
end

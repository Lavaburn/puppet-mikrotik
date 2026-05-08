Puppet::Type.newtype(:mikrotik_traffic_flow) do
  apply_to_all

  # Singleton — name should always be 'traffic_flow'
  newparam(:name) do
    desc 'Name should be -traffic_flow-'
    isnamevar
  end

  ensurable do
    defaultto :present

    newvalue(:present)

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
            return true
          when :enabled
            return (provider.getState == :enabled)
          when :disabled
            return (provider.getState == :disabled)
        end
      }
    end
  end

  newproperty(:active_flow_timeout) do
    desc 'How long to keep active flows in cache (e.g. "1m", "30m")'
  end

  newproperty(:cache_entries) do
    desc 'Maximum number of flows in cache (e.g. "1M", "8M")'
  end

  newproperty(:interfaces, array_matching: :all) do
    desc 'Interfaces to monitor for flows'

    def insync?(is)
      if is.is_a?(Array) && @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

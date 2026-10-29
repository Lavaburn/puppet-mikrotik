Puppet::Type.newtype(:mikrotik_ip_hotspot_walled_garden) do
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
      provider.create
      provider.setState(:enabled)
    end

    newvalue(:disabled) do
      provider.create
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
    desc 'The Walled Garden entry description (comment)'
    isnamevar
  end

  newproperty(:action) do
    desc 'Action to perform (allow/deny)'
    newvalues(:allow, :deny)
  end

  newproperty(:dst_host) do
    desc 'Domain name of the destination web server (wildcards allowed)'
  end

  newproperty(:dst_port) do
    desc 'TCP port(s) the client sends the request to'
  end

  newproperty(:http_path) do
    desc 'The path of the request'
  end

  newproperty(:http_method) do
    desc 'HTTP method of the request'
  end

  newproperty(:server) do
    desc 'Name of the HotSpot server this entry applies to'
  end

  newproperty(:src_address) do
    desc 'Source address of the user sending the request'
  end
end

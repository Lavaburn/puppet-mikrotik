Puppet::Type.newtype(:mikrotik_ip_hotspot_walled_garden_ip) do
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
    desc 'The Walled Garden IP entry description (comment)'
    isnamevar
  end

  newproperty(:action) do
    desc 'Action to perform (accept/drop/reject)'
    newvalues(:accept, :drop, :reject)
  end

  newproperty(:dst_address) do
    desc 'Destination IP address (or network)'
  end

  newproperty(:dst_address_list) do
    desc 'Destination address list'
  end

  newproperty(:protocol) do
    desc 'IP protocol'
  end

  newproperty(:dst_port) do
    desc 'TCP/UDP port(s) (protocol must be tcp or udp)'
  end

  newproperty(:server) do
    desc 'Name of the HotSpot server this entry applies to'
  end

  newproperty(:src_address) do
    desc 'Source address of the user sending the request'
  end
end

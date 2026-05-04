Puppet::Type.newtype(:mikrotik_v7_routing_table) do
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
    desc 'Routing table name'
    isnamevar
  end

  newproperty(:fib) do
    desc 'Whether to create a kernel Forwarding Information Base (FIB) table.'
    newvalues(true, false)
  end

  newproperty(:comment) do
    desc 'Extra comments'
  end
end

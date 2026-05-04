Puppet::Type.newtype(:mikrotik_v7_router_id) do
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
    desc 'Router ID name'
    isnamevar
  end

  newproperty(:id) do
    desc 'The Router ID (IPv4 address format).'
  end

  newproperty(:comment) do
    desc 'Extra comments'
  end
end

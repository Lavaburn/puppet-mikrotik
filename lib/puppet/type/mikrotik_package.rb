Puppet::Type.newtype(:mikrotik_package) do
  apply_to_all

  ensurable do
    defaultto :enabled

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
        return (provider.getState == should)
      }
    end
  end

  newparam(:name) do
    desc 'Package Name'
    isnamevar
  end

  newparam(:force_reboot) do
    desc 'Whether to reboot after downloading package'
    newvalues(true, false)
  end
end

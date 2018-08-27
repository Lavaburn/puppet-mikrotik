Puppet::Type.newtype(:mikrotik_upgrade) do
  apply_to_all

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create  
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:downloaded) do
      provider.create  
      provider.setState(:downloaded)      
    end

    newvalue(:installed) do
      provider.create  
      provider.setState(:installed)
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
          when :downloaded                   
            return (provider.getState == :downloaded or provider.getState == :installed)
          when :installed                      
            return (provider.getState == :installed)       
        end
      }
    end
  end

  newparam(:name) do
    desc 'Firmware Version'
    isnamevar
  end

  newparam(:force_reboot) do
    desc 'Whether to reboot after downloading package'
    newvalues(true, false)
  end
end

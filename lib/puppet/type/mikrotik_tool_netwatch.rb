Puppet::Type.newtype(:mikrotik_tool_netwatch) do
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
    desc 'IP/Hostname to test'
    isnamevar
  end
  
  newproperty(:interval) do
    desc 'Interval between checks in seconds.'
  end
  
  newproperty(:timeout) do
    desc 'Timeout in seconds after which the host is considered down.'
  end
  
  newproperty(:down_script) do
    desc 'Script that is started when host goes down.'
  end
  
  newproperty(:up_script) do
    desc 'Script that is started when host goes up.'
  end

  newproperty(:comment) do
    desc 'Short description'
  end
end

Puppet::Type.newtype(:mikrotik_schedule) do
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
    desc 'Scheduled event name'
    isnamevar
  end
  
  newproperty(:start_date) do
    desc 'Date of first execution'
  end
  
  newproperty(:start_time) do
    desc 'Time of first execution'
  end
  
  newproperty(:interval) do
    desc 'Interval between two script executions'
  end

  newproperty(:policies, :array_matching => :all) do
    desc 'The permissions that the script is given.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:on_event) do
    desc 'Script name or actual commands to execute'
  end
end

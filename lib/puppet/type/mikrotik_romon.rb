Puppet::Type.newtype(:mikrotik_romon) do
  apply_to_all
  
  # Only 1 set of settings.
  newparam(:name) do
    desc 'Name should be -romon-'
    isnamevar
  end

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

  newproperty(:id) do
    desc 'The RoMON ID (MAC address).'
  end
  
  newproperty(:secrets, :array_matching => :all) do
    desc 'The default RoMON passwords for this router.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end    
  end  
end

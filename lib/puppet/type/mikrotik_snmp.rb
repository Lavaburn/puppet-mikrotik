Puppet::Type.newtype(:mikrotik_snmp) do
  # Only 1 set of settings.
  newparam(:name) do
    desc 'Name should be -snmp-'
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

  newproperty(:contact) do
    desc 'The SNMP contact information.'
  end

  newproperty(:location) do
    desc 'The SNMP location information.'
  end
  
  newproperty(:trap_targets, :array_matching => :all) do
    desc 'The SNMP trap targets.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end    
  end
  
  newproperty(:trap_community) do
    desc 'The SNMP trap community.'
  end
  
  newproperty(:trap_version) do
    desc 'The SNMP trap version.'
    newvalues(1, 2, 3)
  end
  
  newproperty(:trap_generators, :array_matching => :all) do
    desc 'The objects that generate SNMP traps.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end    
  end
end

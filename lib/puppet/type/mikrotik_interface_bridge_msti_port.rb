Puppet::Type.newtype(:mikrotik_interface_bridge_msti_port) do
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
    desc 'Unique name for Port MST Override'
    isnamevar
  end
  
  newproperty(:interface) do
    desc 'The interface to apply this config.'
  end
  
  newproperty(:identifier) do
    desc 'The MST Instance identifier (1-32).'
  end

  newproperty(:priority) do
    desc 'The port priority within the MST Instance. Default: 0x80 (hex)'
  end
  
  newproperty(:internal_path_cost) do
    desc 'The port cost within the MST Instance. Default: 10'
  end
end

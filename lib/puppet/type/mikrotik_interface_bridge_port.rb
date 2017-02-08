Puppet::Type.newtype(:mikrotik_interface_bridge_port) do
  apply_to_device

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
  
  newparam(:interface) do
    desc 'Name of the interface'
    isnamevar
  end

  newproperty(:bridge) do
    desc 'The bridge interface the respective interface is grouped in'
  end
  
  # Not frequently used settings:
  ## priority -- The priority of the interface in comparison with other going to the same subnet
  ## path-cost -- Path cost to the interface, used by STP to determine the 'best' path
  ## horizon --   
  ## edge -- 
  ## point-to-point -- 
  ## external-fdb -- 
  ## auto-isolate -- 
end

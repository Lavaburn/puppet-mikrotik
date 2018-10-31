Puppet::Type.newtype(:mikrotik_ospf_nmba_neighbor) do
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
    desc 'Neighbor Address'
    isnamevar
  end
  
  newproperty(:instance) do
    desc 'The OSPF Instance this neighbor belongs to.'
  end
  
  newproperty(:poll_interval) do
    desc 'The interval at which the neighbor should be polled (Defaults to 2 minutes)'
  end
  
  newproperty(:priority) do
    desc 'The OSPF priority used when the neighbor is down'
  end
end

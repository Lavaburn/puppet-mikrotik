Puppet::Type.newtype(:mikrotik_mpls_te_interface) do
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
    desc 'Interface name'
    isnamevar
  end

  newproperty(:bandwidth) do
    desc 'Interface Bandwidth'
  end

  newproperty(:k_factor) do
    desc 'Value used to calculate RSVP timeout.'
  end
  
  newproperty(:refresh_time) do
    desc 'Interval in which RSVP Path messages are sent out.'
  end
  
  # Less frequently used options:
  ## resource-class -- 
  ## use-udp -- 
  ## blockade-k-factor -- 
  ## te-metric -- 
  ## igp-flood-period -- 
  ## up-flood-thresholds -- 
  ## down-flood-thresholds -- 
  
  ## comment -- Not visible on Winbox?
end

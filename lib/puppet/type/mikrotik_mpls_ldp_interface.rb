Puppet::Type.newtype(:mikrotik_mpls_ldp_interface) do
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

  newproperty(:hello_interval) do
    desc 'MPLS Interface Hello Interval'
    #defaultto "5s"
  end
  
  newproperty(:hold_time) do
    desc 'MPLS Interface Hold Time'
    #defaultto "15s"
  end

  newproperty(:transport_address) do
    desc 'Transport address for LDP'
  end

  newproperty(:accept_dynamic_neighbors) do
    desc 'Whether to accept dynamic neighbors (Default = true)'
    newvalues(true, false)
    defaultto true
  end
end

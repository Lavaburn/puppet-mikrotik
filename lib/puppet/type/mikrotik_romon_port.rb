Puppet::Type.newtype(:mikrotik_romon_port) do
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
  
  newproperty(:forbid) do
    desc 'Whether to forbid RoMON traffic on this interface (default = allow).'
    newvalues(true, false)
    defaultto false
  end

  newproperty(:secrets, :array_matching => :all) do
    desc 'The RoMON passwords specific to this interface.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end    
  end
  
  newproperty(:cost) do
    desc 'The cost for this interface.'
    defaultto 100
  end
end

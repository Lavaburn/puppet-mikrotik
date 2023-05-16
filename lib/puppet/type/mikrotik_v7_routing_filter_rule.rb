Puppet::Type.newtype(:mikrotik_v7_routing_filter_rule) do
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

  # General
  newparam(:name) do
    desc 'Routing Filter Rule name (see comments)'
    isnamevar
  end

  newproperty(:chain) do
    desc 'The routing filter chain'
  end

  newproperty(:chain_order) do
    desc 'Order number inside the chain (starts at 1).'
  end
  
  newproperty(:rule) do
    desc 'The routing filter rule'
  end
end

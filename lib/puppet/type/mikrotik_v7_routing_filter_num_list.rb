Puppet::Type.newtype(:mikrotik_v7_routing_filter_num_list) do
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
    desc 'Routing Filter Num list name (see comments)'
    isnamevar
  end

  newproperty(:list) do
    desc 'The routing filter num list'
  end

  newproperty(:range) do
    desc 'The routing filter num list range'
  end
end

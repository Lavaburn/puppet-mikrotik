Puppet::Type.newtype(:mikrotik_bgp_aggregate) do
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
  
  newparam(:name) do
    desc 'Network (CIDR IP) to aggregate'
    isnamevar
  end
  
  newproperty(:instance) do
    desc 'The BGP Instance (AS).'
  end

  newproperty(:summary_only) do
    desc 'Whether to supress smaller networks that belong to this aggregate.'
    newvalues(true, false)
  end
    
  newproperty(:inherit_attributes) do
    desc 'Whether the aggregate should use attributes from aggregated networks.'
    newvalues(true, false)
  end

  newproperty(:include_igp) do
    desc 'Whether to include IGP networks.'
    newvalues(true, false)
  end
  
  newproperty(:attribute_filter) do
    desc 'Routing filters to use for setting attributes.'
  end
  
  newproperty(:suppress_filter) do
    desc 'Routing filters to use for supressing routes.'
  end

  newproperty(:advertise_filter) do
    desc 'Routing filters to use for advertisements.'
  end  
end

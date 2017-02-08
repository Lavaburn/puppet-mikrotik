Puppet::Type.newtype(:mikrotik_ip_route_rule) do
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
  
  newparam(:name) do
    desc 'Rule description'
    isnamevar
  end

  newproperty(:src_address) do
    desc 'Source Address'
  end

  newproperty(:dst_address) do
    desc 'Destination Address'
  end

  newproperty(:routing_mark) do
    desc 'Routing mark set by firewall mangle'
  end

  newproperty(:interface) do
    desc 'Interface of incoming traffic'
  end

  newproperty(:action) do
    desc 'Action to take with selected traffic'
    newvalues(:lookup, :drop, :unreachable)
  end

  newproperty(:table) do
    desc 'Table to lookup routes in if action == "lookup"'
  end
  
#  newproperty(:sequence) do
#    desc 'Ordering of the rule'
#  end
end

Puppet::Type.newtype(:mikrotik_bgp_instance_vrf) do
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
    desc 'The routing mark / VRF to inject into the instance.'
    isnamevar
  end

  newparam(:instance) do
    desc 'BGP Instance name'
  end
  
  newproperty(:redistribute_connected) do
    desc 'Whether to redistribute connected routes to the instance.'
    newvalues(true, false)
  end

  newproperty(:redistribute_static) do
    desc 'Whether to redistribute static routes to the instance.'
    newvalues(true, false)
  end

  newproperty(:redistribute_rip) do
    desc 'Whether to redistribute RIP routes to the instance.'
    newvalues(true, false)
  end
  
  newproperty(:redistribute_ospf) do
    desc 'Whether to redistribute OSPF routes to the instance.'
    newvalues(true, false)
  end
  
  newproperty(:redistribute_bgp) do
    desc 'Whether to redistribute BGP routes from other instances to the instance.'
    newvalues(true, false)
  end

  newproperty(:in_filter) do
    desc 'The input filter applying to the injection.'
  end
  
  newproperty(:out_filter) do
    desc 'The output filter applying to the injection.'
  end
end

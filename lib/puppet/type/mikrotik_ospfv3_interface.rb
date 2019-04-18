Puppet::Type.newtype(:mikrotik_ospfv3_interface) do
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
    desc 'OSPFv3 Interface'
    isnamevar
  end

  newproperty(:area) do
    desc 'The OSPFv3 area to assign the interface to.'
  end  
  
  newproperty(:cost) do
    desc 'The Cost of the OSPFv3 interface.'
  end
  
  newproperty(:priority) do
    desc 'The Priority of the OSPF interface.'
  end
    
  newproperty(:network_type) do # network-type
    desc 'The network type (default, broadcast, nbma, point-to-point, ptmp)'
    newvalues(:default, :broadcast, :nbma, 'point-to-point', :ptmp)
    defaultto :broadcast
  end
  
  newproperty(:passive) do
    desc 'Whether the interface is passive (not participating in OSPF)'
    newvalues(false, true)
    defaultto false
  end
  
  newproperty(:use_bfd) do # use-bfd
    desc 'Whether to enable BFD on the interface for the OSPF process'
    newvalues(false, true)
    defaultto false
  end
end

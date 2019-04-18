Puppet::Type.newtype(:mikrotik_ipv6_address) do
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
  
  newparam(:address) do
    desc 'IP Address (CIDR notation)'
    isnamevar
  end
  
  newproperty(:interface) do
    desc 'Interface to attach the IP address on.'
  end
  
  newproperty(:advertise) do
    desc 'Whether to advertise (RA) the network.'
    newvalues(true, false)
  end
  
  newproperty(:eui64) do
    desc 'Whether to set up full address using MAC address.'
    newvalues(true, false)
  end
  
  newproperty(:from_pool) do
    desc 'The DHCP pool to use a network from.'
  end
end

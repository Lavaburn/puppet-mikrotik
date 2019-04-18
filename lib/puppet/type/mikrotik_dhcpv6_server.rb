Puppet::Type.newtype(:mikrotik_dhcpv6_server) do
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
    desc 'Name of the DHCPv6 server instance'
    isnamevar
  end

  newproperty(:interface) do
    desc 'Interface to attach the DHCPv6 server to'
  end  
    
  newproperty(:lease_time) do
    desc 'Lease time for IPv6 leases'
  end
    
  newproperty(:address_pool) do
    desc 'IPv6 address pool to lease addresses from'
  end
end

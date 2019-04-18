Puppet::Type.newtype(:mikrotik_dhcpv6_client) do
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
    desc 'Interface to listen on for DHCPv6 packets'
    isnamevar
  end

  newproperty(:request_address) do
    desc 'Whether to request IPv6 address from DHCP server.'
    newvalues(true, false)
  end
  
  newproperty(:request_prefix) do
    desc 'Whether to request IPv6 prefix from DHCP server.'
    newvalues(true, false)
  end
  
  newproperty(:pool_name) do
    desc 'Name of Pool to be created on receiving prefix.'
  end

  newproperty(:pool_prefix_length) do
    desc 'Prefix size for pool to be created on receiving prefix.'
  end
  
  newproperty(:prefix_hint) do
    desc 'Prefix Hint (?)'
  end
  
  newproperty(:use_peer_dns) do
    desc 'Whether to use DNS provided by DHCP server.'
    newvalues(true, false)
  end

  newproperty(:add_default_route) do
    desc 'Whether to use default route provided by DHCP server.'
    newvalues(true, false)
  end
end

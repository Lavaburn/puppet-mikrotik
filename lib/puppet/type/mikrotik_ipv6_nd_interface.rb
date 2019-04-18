Puppet::Type.newtype(:mikrotik_ipv6_nd_interface) do
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
  
  newparam(:interface) do
    desc 'Interface to run Neighbor Discovery on'
    isnamevar
  end
  
  newproperty(:ra_interval) do  # ra-interval
    desc 'Interval (s) for Router Advertisements.'
  end
  
  newproperty(:ra_delay) do  # ra-delay
    desc 'Delay (s) for Router Advertisements.'
  end

  newproperty(:mtu) do
    desc 'MTU.'
  end

  newproperty(:reachable_time) do  # reachable-time
    desc 'Reachable Time (s).'
  end

  newproperty(:retransmit_interval) do  # retransmit-interval
    desc 'Retransmit Interval (s).'
  end

  newproperty(:ra_lifetime) do  # ra-lifetime
    desc 'RA Lifetime.'
  end

  newproperty(:hop_limit) do  # hop-limit
    desc 'Hop Limit.'
  end
  
  newproperty(:advertise_mac) do  # advertise-mac-address
    desc 'Whether to advertise DNS in the RA'
    newvalues(true, false)
  end

  newproperty(:advertise_dns) do  # advertise-dns
    desc 'Whether to advertise DNS in the RA'
    newvalues(true, false)
  end
  
  newproperty(:managed_address_config) do  # managed-address-configuration
    desc 'Whether to advertise DNS in the RA'
    newvalues(true, false)
  end
  
  newproperty(:other_config) do  # other-configuration
    desc 'Whether to advertise DNS in the RA'
    newvalues(true, false)
  end
end

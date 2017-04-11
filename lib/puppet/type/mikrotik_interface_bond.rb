Puppet::Type.newtype(:mikrotik_interface_bond) do
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
    desc 'The bonding interface name'
    isnamevar
  end
  
  newproperty(:mtu) do
    desc 'Maximum Transmit Unit'
  end

  newproperty(:arp) do
    desc 'Address Resolution Protocol to use'
    newvalues('enabled', 'disabled', 'proxy-arp', 'reply-only')
  end

  newproperty(:arp_timeout) do
    desc 'Address Resolution Protocol Timeout'
  end

  newproperty(:slaves, :array_matching => :all) do
    desc 'Interfaces that are used in bonding'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:mode) do
    desc 'Interface bonding mode'
    newvalues('802.3ad', 'active-backup', 'balance-alb', 'balance-rr', 'balance-tlb', 'balance-xor', 'broadcast')
  end
  
  newproperty(:link_monitoring) do
    desc 'Method for monitoring the link'
    newvalues('arp', 'mii', 'none')
  end
  
  newproperty(:transmit_hash_policy) do
    desc 'Transmit Hash Policy'
    newvalues('layer-2', 'layer-2-and-3', 'layer-3-and-4')
  end
  
  newproperty(:primary) do
    desc 'Slave that will be used in active-backup mode as active link'
  end
  
  # Not frequently used settings:
  ## min-links -- 
  ## down-delay -- Time period the interface is disabled  if a link failure has been detected
  ## up-delay -- Time period the interface is disabled if a link has been brought up
  ## lacp-rate -- Link Aggregation Control Protocol rate specifies how often to exchange with LACPDUs between bonding peer
  ## mii-interval -- Time in milliseconds for monitoring mii-type link
  ## arp-interval -- Time in milliseconds for monitoring ARP requests
  ## arp-ip-targets -- IP addresses for monitoring
end

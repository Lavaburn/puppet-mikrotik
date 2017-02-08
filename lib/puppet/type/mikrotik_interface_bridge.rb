Puppet::Type.newtype(:mikrotik_interface_bridge) do
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
    desc 'The bridge name'
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

  newproperty(:admin_mac) do
    desc 'The administrative MAC address'
  end
  
  # STP settings:
  ## protocol-mode -- 
  ## priority -- Bridge interface priority
  ## max-message-age -- Time to remember Hello messages received from other bridges
  ## forward-delay -- Time which is spent in listening/learning state
  ## transmit-hold-count -- 
  ## ageing-time -- Time the information about host will be kept in the the data base  
end

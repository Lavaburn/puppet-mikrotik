Puppet::Type.newtype(:mikrotik_interface_bridge) do
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

  newproperty(:igmp_snooping) do
    desc 'Whether to enable IGMP snooping'
    newvalues(true, false)
  end

  newproperty(:dhcp_snooping) do
    desc 'Whether to enable DHCP snooping'
    newvalues(true, false)
  end

  newproperty(:fast_forward) do
    desc 'Whether to enable FastPath/Hardware Acceleration'
    newvalues(true, false)
  end

  # STP
  newproperty(:protocol_mode) do
    desc 'Bridge protection mode: none, STP, RSTP, MSTP'
    newvalues('none', 'stp', 'rstp', 'mstp')
  end
  
  newproperty(:priority) do
    desc 'Bridge interface priority: hexidecimal, defaults to 0x8000'
  end
  
  # MSTP
  newproperty(:region_name) do
    desc 'MSTP Region Name'
  end

  newproperty(:region_revision) do
    desc 'MSTP Region Revision'
  end
  
  # VLAN 
  newproperty(:vlan_filtering) do
    desc 'Whether to enable VLAN filtering'
    newvalues(true, false)
  end

  newproperty(:pvid) do
    desc 'Bridge VLAN ID (untagged)'
  end

  newproperty(:ether_type) do
    desc 'Bridge Ether Type'
    newvalues('0x8100', '0x88a8', '0x9100')
  end
  
  newproperty(:frame_types) do
    desc 'Allow Frame Types'
    newvalues('admit-all', 'admit-only-untagged-and-priority-tagged', 'admit-only-vlan-tagged')
  end
  
  newproperty(:ingress_filtering) do
    desc 'Whether to enable ingress filtering'
    newvalues(true, false)
  end
  
  newproperty(:comment) do
    desc 'Comments'
  end
  
  # Less frequently used options:  
  
  ##  ageing-time -- Time the information about host will be kept in the the data base
  ##  auto-mac --   
  
  # STP  
  ##  max-message-age -- Time to remember Hello messages received from other bridges
  ##  forward-delay -- Time which is spent in listening/learning state
  ##  transmit-hold-count -- 
  ##  max-hops --
  
  # DHCP snooping 
  ##  add-dhcp-option82 -- 
  
  # IGMP snooping
  ##  igmp-version -- 
  ##  multicast-router -- 
  ##  multicast-querier -- 
  ##  startup-query-count -- 
  ##  last-member-query-count -- 
  ##  last-member-interval -- 
  ##  membership-interval -- 
  ##  querier-interval -- 
  ##  query-interval -- 
  ##  query-response-interval -
  ##  startup-query-interval -- 
end

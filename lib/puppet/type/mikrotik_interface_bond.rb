Puppet::Type.newtype(:mikrotik_interface_bond) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used

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

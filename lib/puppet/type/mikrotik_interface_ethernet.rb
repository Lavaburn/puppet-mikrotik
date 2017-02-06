Puppet::Type.newtype(:mikrotik_interface_ethernet) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used

  newparam(:name) do
    desc 'The original ethernet name (auto detected, not changeable)'
    isnamevar
  end
  
  newproperty(:alias) do
    desc 'The actual interface name'
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
  
  newproperty(:auto_negotiation) do
    desc 'When enabled the interface "advertises" the maximum capabilities to achieve the best connection possible'
  end

  newproperty(:advertise, :array_matching => :all) do
    desc 'Speed and duplex mode to advertise'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  # Not frequently used settings:
  ## loop-protect -- 
  ## loop-protect-disable-time -- 
  ## loop-protect-send-interval --  
end

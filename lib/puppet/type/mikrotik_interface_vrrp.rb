Puppet::Type.newtype(:mikrotik_interface_vrrp) do
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
    desc 'The VRRP interface name'
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

  newproperty(:interface) do
    desc 'Interface to attach VRRP address to. Interface should have IP set in same subnet (?)'
  end
  
  newproperty(:vrid) do
    desc 'Unique ID'
  end
  
  newproperty(:priority) do
    desc 'Priority of this peer'
  end
  
  newproperty(:interval) do
    desc 'Interval (seconds) for peer communication'
  end
  
  newproperty(:preemption_mode) do
    desc 'Whether to enable preemption for peer communication'
    newvalues(true, false)
    defaultto true
  end
  
  newproperty(:authentication) do
    desc 'Authentication mode to use for peer communication'
    newvalues('none', 'simple', 'ah')
    defaultto 'none'
  end
  
  newproperty(:password) do
    desc 'Password to use when authentication is enabled'
  end
  
  newproperty(:version) do
    desc 'Version of VRRP Protocol'
    newvalues(2, 3)
    defaultto 3
  end
  
  newproperty(:v3_protocol ) do
    desc 'IP version'
    newvalues('ipv4', 'ipv6')
    defaultto 'ipv4'
  end

  newproperty(:on_master) do
    desc 'Script to run when interface becomes Master'
  end

  newproperty(:on_backup) do
    desc 'Script to run when interface becomes Backup'
  end
end

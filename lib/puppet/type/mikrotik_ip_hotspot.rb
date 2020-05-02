Puppet::Type.newtype(:mikrotik_ip_hotspot) do
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
    desc 'The Hotspot Server name'
    isnamevar
  end
  
  newproperty(:address_pool) do
    desc 'IP address pool name'
  end
  
  newproperty(:addresses_per_mac) do
    desc 'Maximum count of IP addresses for one MAC address'
  end
  
  newproperty(:idle_timeout) do
    desc 'Maximal period of inactivity for unauthorized clients'
  end
  
  newproperty(:interface) do
    desc 'Interface to run HotSpot service on'
  end
  
  newproperty(:keepalive_timeout) do
    desc 'Keepalive timeout for unauthorized clients'
  end

  newproperty(:login_timeout) do
    desc 'Login timeout when authenticating'
  end

  newproperty(:profile) do
    desc 'Configuration for hotspot server'
  end  
end

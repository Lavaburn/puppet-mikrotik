Puppet::Type.newtype(:mikrotik_interface_ppp) do
  apply_to_all
  
  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.create if retrieve == :absent
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
    desc 'The interface name'
    isnamevar
  end

  newproperty(:ppp_type) do
    desc 'only ovpn_client supported so far'
    defaultto 'ovpn_client'
  end

  newproperty(:max_mtu) do
    desc 'Maximum Transmission Unit'
  end

  newproperty(:mac_address) do
    desc '(OVPN) MAC address of the interface (normally auto-generated)'
  end

  newproperty(:connect_to) do
    desc '(OVPN) The remote address to connect to'
  end

  newproperty(:port) do
    desc '(OVPN) The port the server is listening on'
    defaultto '1194'
  end

  newproperty(:mode) do
    desc '(OVPN) IP (tunnel) mode or Ethernet (bridge/tap) mode'
    newvalue(:ip)
    newvalue(:ethernet)
  end

  newproperty(:user) do
    desc 'The username to connect as'
  end

  newproperty(:password) do
    desc 'The password to connect with'
  end

  newproperty(:profile) do
    desc 'The profile to use'
  end

  autorequire(:mikrotik_ppp_profile) do
    self[:profile]
  end

  newproperty(:certificate) do
    desc '(OVPN) name of Certificate file'
  end

  newproperty(:add_default_route) do
    newvalue(:true)
    newvalue(:false)
  end

  newproperty(:authentication) do
    desc 'Authentication algorithm'
  end

  newproperty(:cipher) do
    desc '(OVPN) Cipher algorithm'
  end

end

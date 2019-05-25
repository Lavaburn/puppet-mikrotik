Puppet::Type.newtype(:mikrotik_ppp_server) do
  apply_to_all
  
  ensurable do
    newvalue(:present)

    newvalue(:enabled) do
      provider.setState(:enabled)
    end

    newvalue(:disabled) do
      provider.setState(:disabled)
    end

    defaultto :present
    
    def retrieve
      provider.getState
    end

    def insync?(is)
      @should.each { |should|
        case should
          when :present
            return true
          when :enabled
            return (provider.getState == :enabled)
          when :disabled
            return (provider.getState == :disabled)
        end
      }
    end
  end

  newparam(:name) do
    desc 'Name should be -pptp- or -l2tp-'
    isnamevar
  end

  newproperty(:max_mtu) do
    desc 'Maximum Transmission Unit'
  end
  
  newproperty(:max_mru) do
    desc 'Maximum Receive Unit'
  end
  
  newproperty(:mrru) do
    desc 'Maximum Receive Reconstructed Unit'
  end
  
  newproperty(:authentication, :array_matching => :all) do
    desc 'Authentication algorithms'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
 
  newproperty(:keepalive_timeout) do
    desc 'Time after which an inactive session should be disconnected'
  end
  
  newproperty(:default_profile) do
    desc 'Default profile to use'
  end
  
  # L2TP Only  
  newproperty(:max_sessions) do
    desc '(L2TP) The maximum number of sessions allowed on the server'
  end

  newproperty(:use_ipsec) do
    desc '(L2TP) Whether to use IPSEC encryption'
  end
  
  newproperty(:ipsec_secret) do
    desc '(L2TP) IPSEC Secret'
  end
  
  newproperty(:allow_fastpath) do
    desc '(L2TP) Whether to allow Fast Path'
  end

  #OVPN Only
  newproperty(:port) do
    desc '(OVPN) Port to run the server on'
  end

  newproperty(:mode) do
    desc '(OVPN) IP (tunnel) mode or Ethernet (bridge/tap) mode'
    newvalue(:ip)
    newvalue(:ethernet)
  end

  newproperty(:netmask) do
    desc '(OVPN) Subnet mask to be applied to clients'
  end

  newproperty(:mac_address) do
    desc '(OVPN) MAC address of the server (normally auto-generated)'
  end

  newproperty(:certificate) do
    desc '(OVPN) name of Certificate file'
  end

  newproperty(:require_client_certificate) do
    newvalue(:true)
    newvalue(:false)
  end

  newproperty(:cipher, :array_matching => :all) do
    desc '(OVPN) Cipher algorithms'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

end

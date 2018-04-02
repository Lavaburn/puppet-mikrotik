Puppet::Type.newtype(:mikrotik_interface_gre) do
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
    desc 'The GRE tunnel name'
    isnamevar
  end

  newproperty(:mtu) do
    desc 'Maximum Transmit Unit'
  end

  newproperty(:local_address) do
    desc 'IP Address for this side of the tunnel'
  end

  newproperty(:remote_address) do
    desc 'IP Address for the remote side of the tunnel'
  end

  newproperty(:ipsec_secret) do
    desc 'Shared secret if IPSEC encryption is being used'
  end

  newproperty(:keepalive) do
    desc 'Time to keep the tunnel alive if no traffic is seen'
  end

  newproperty(:dscp) do
    desc 'The DSCP value (QoS)'
  end

  newproperty(:dont_fragment) do
    desc 'Whether to allow packet fragmentation in the tunnel'
    newvalues('inherit', 'no')
  end

  newproperty(:clamp_tcp_mss) do
    desc 'Whether to clamp the TCP MSS (?)'
    newvalues(false, true)
    defaultto true
  end

  newproperty(:allow_fast_path) do
    desc 'Whether to allow Fast Path Routing'
    newvalues(false, true)
    defaultto true
  end
end

Puppet::Type.newtype(:mikrotik_interface_pppoe_server) do
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
    desc 'The PPPoE Service name (service-name)'
    isnamevar
  end

  newproperty(:interface) do
    desc 'The interface on which to set up the service'
  end
  
  newproperty(:max_mtu) do
    desc 'Maximum Transmit Unit'
  end

  newproperty(:max_mru) do
    desc 'Maximum Receive Unit'
  end
  
  newproperty(:mrru) do
    desc 'MRRU'
  end
  
  newproperty(:keepalive) do
    desc 'Time to keep the tunnel alive if no traffic is seen'
  end
  
  newproperty(:default_profile) do
    desc 'The default user profile'
  end  
  
  newproperty(:one_session_per_host) do
    desc 'One session per host'
    newvalues(false, true)
  end
  
  newproperty(:max_sessions) do
    desc 'The maximum number of sessions on this service'
  end
  
  newproperty(:pado_delay) do
    desc 'PADO delay in ms'
  end
  
  newproperty(:authentication, :array_matching => :all) do
    desc 'List of authentication methods (pap, chap, mschap1/2)'
        
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

Puppet::Type.newtype(:mikrotik_ppp_secret) do
  ensurable do    
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

    defaultto :present
    
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
    desc 'Name of the user'
    isnamevar
  end

  newproperty(:password) do
    desc 'User password'
  end

  newproperty(:service) do
    desc 'Specifies service that will use this user'
  end

  newproperty(:caller_id) do
    desc 'Sets IP address for PPTP, L2TP or MAC address for PPPoE'
  end

  newproperty(:profile) do
    desc 'Profile name for the user'
  end

  newproperty(:local_address) do
    desc 'Assigns an individual address to the PPP-server'
  end

  newproperty(:remote_address) do
    desc 'Assigns an individual address to the PPP-client'
  end

  newproperty(:routes, :array_matching => :all) do
    desc 'Routes that appear on the server when the client is connected'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:limit_bytes_in) do
    desc 'Maximum amount of bytes user can transmit'
  end
  
  newproperty(:limit_bytes_out) do
    desc 'Maximum amount of bytes user can receive'
  end
end

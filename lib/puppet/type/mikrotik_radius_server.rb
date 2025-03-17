Puppet::Type.newtype(:mikrotik_radius_server) do
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
    desc 'The server description'
    isnamevar
  end
  
  newproperty(:address) do
    desc 'The server IP address.'
  end

  newproperty(:services, :array_matching => :all) do
    desc 'The services that the server will handle requests for.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:called_id) do
    desc 'The called ID.'
  end
  
  newproperty(:domain) do
    desc 'The domain to add to the username (?)'
  end
    
  newproperty(:secret) do
    desc 'The RADIUS shared secret.'
  end
  
  newproperty(:auth_port) do
    desc 'The RADIUS authentication port.'
  end
  
  newproperty(:acct_port) do
    desc 'The RADIUS accounting port.'
  end
  
  newproperty(:timeout) do
    desc 'The RADIUS timeout.'
  end
  
  newproperty(:accounting_backup) do
    desc 'Accounting backup (?)'
  end
  
  newproperty(:realm) do
    desc 'The realm that this server will listen for.'
  end
  
  newproperty(:src_address) do
    desc 'The source IP that will be used for requests.'
  end

  newproperty(:require_msg_auth) do
    desc 'Whether to require message authentication.'
    newvalues('no', 'yes-for-request-resp')
  end

  newproperty(:protocol) do
    desc 'The protocol to use (UDP or RadSec).'
    newvalues('udp', 'radsec')
  end
end

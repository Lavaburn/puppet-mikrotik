Puppet::Type.newtype(:mikrotik_interface_ppp_server_binding) do
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
    desc 'only ovpn supported so far'
    defaultto 'ovpn'
  end

  newproperty(:user) do
    desc 'The username to connect as'
  end

  newproperty(:comment) do
    desc 'A comment'
  end

end

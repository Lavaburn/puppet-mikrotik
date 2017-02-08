Puppet::Type.newtype(:mikrotik_ip_service) do
  apply_to_device

  ensurable do
    defaultto :present

    newvalue(:present)
    
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
    desc 'The IP service name'
    isnamevar
  end

  newproperty(:port) do
    desc 'The port on which the service is listening'
  end

  newproperty(:addresses, :array_matching => :all) do
    desc 'The IP addresses assigned to the list'
    
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

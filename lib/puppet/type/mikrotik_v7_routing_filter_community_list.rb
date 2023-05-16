Puppet::Type.newtype(:mikrotik_v7_routing_filter_community_list) do
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

  # General
  newparam(:name) do
    desc 'Routing Filter Community List name (see comments)'
    isnamevar
  end
  
  newproperty(:type) do
    desc 'The type of BGP communities'
    newvalues(:normal, :extended, :large)
    defaultto :normal    
  end

  newproperty(:list) do
    desc 'A list name'
  end
  
  newproperty(:communities, :array_matching => :all) do
    desc 'A list of BGP communities'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:regexp) do
    desc 'The regular expression filtering BGP communities'
  end
end

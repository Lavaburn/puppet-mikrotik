Puppet::Type.newtype(:mikrotik_mpls_te_path) do
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
    desc 'Path name'
    isnamevar
  end

  newproperty(:use_cspf) do
    desc 'Whether to use dynamic OSPF paths. Default: true'   # Winbox behaviour does not match console/api
    newvalues(true, false)
  end
  
  newproperty(:record_route) do
    desc 'Whether to record route'
    newvalues(true, false)
  end

  newproperty(:hops, :array_matching => :all) do
    desc 'List of static hops. Format: IP:loose/strict'
        
    # DO NOT SORT !
    #    def insync?(is)
    #      if is.is_a?(Array) and @should.is_a?(Array)
    #        is.sort == @should.sort
    #      else
    #        is == @should
    #      end
    #    end
  end
  
  # Less frequently used options:
  ## affinity-include-all -- 
  ## affinity-include-any -- 
  ## affinity-exclude -- 
  ## reoptimize-interval -- Used by CSPF 

  ## comment -- Not visible on Winbox?
end

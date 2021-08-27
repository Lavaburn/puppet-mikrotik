Puppet::Type.newtype(:mikrotik_interface_te) do
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
    desc 'Interface name'
    isnamevar
  end

  newproperty(:mtu) do
    desc 'Interface MTU (L3)'
  end
  
  newproperty(:from_address) do
    desc 'Establish Tunnel from this IP'
  end
  
  newproperty(:to_address) do
    desc 'Establish Tunnel to this IP'
  end

  newproperty(:bandwidth) do
    desc 'Bandwidth that the tunnel reserves by default'
  end

  newproperty(:primary_path) do
    desc 'MPLS-TE Tunnel path to use primarily'
  end

  newproperty(:secondary_paths, :array_matching => :all) do
    desc 'MPLS-TE Tunnel paths to fail over on'

# DO NOT SORT !
#    def insync?(is)
#      if is.is_a?(Array) and @should.is_a?(Array)
#        is.sort == @should.sort
#      else
#        is == @should
#      end
#    end
  end
  
  # TE
  newproperty(:record_route) do
    desc 'Whether to record route'
    newvalues(true, false)
  end
  
  # Bandwidth
  newproperty(:bandwidth_limit) do
    desc 'Actual bandwidth limit to enforce (%)'
  end
  
  newproperty(:auto_bandwidth_range) do
    desc 'Minimum and Maximum Bandwidth to reserve. Firmat: min-max'
  end
  
  newproperty(:auto_bandwidth_reserve) do
    desc 'Additional bandwidth to reserve (%)'
  end
    
  # Less frequently used options:
  ##  disable-running-check -- 
  
  # TE
  ## primary-retry-interval -- 
  ## setup-priority --
  ## holding-priority --   
  ## affinity-include-all -- 
  ## affinity-include-any -- 
  ## affinity-exclude -- 
  ## reoptimize-interval -- Used by CSPF 
  
  # Bandwidth
  ## auto-bandwidth-avg-interval -- 
  ## auto-bandwidth-update-interval -- 

  ## comment -- Not visible on Winbox?
end

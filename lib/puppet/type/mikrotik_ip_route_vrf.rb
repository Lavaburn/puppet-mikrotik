Puppet::Type.newtype(:mikrotik_ip_route_vrf) do
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
  
  newparam(:routing_mark) do
    desc 'Routing Mark/Table Name'
    isnamevar
  end
  
  newproperty(:interfaces, :array_matching => :all) do
    desc 'Interfaces to attach to VRF'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:route_distinguisher) do
    desc 'Route Destinguisher (BGP/MPLS ?)'
  end
  
  newproperty(:import_route_targets, :array_matching => :all) do
    desc 'Import Route Targets (BGP/MPLS ?)'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:export_route_targets, :array_matching => :all) do
    desc 'Export Route Targets (BGP/MPLS ?)'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  # Not in Winbox:
    # bgp-nexthop
end

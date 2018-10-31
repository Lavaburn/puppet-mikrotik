Puppet::Type.newtype(:mikrotik_interface_bgp_vpls) do
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

  newproperty(:route_distinguisher) do
    desc 'Route Distinguisher (X:Y) [eg. ASN:IP]'
  end
  
  newproperty(:import_route_targets, :array_matching => :all) do
    desc 'Import Route Targets (X:Y) [eg. ASN:IP]'
  end
  
  newproperty(:export_route_targets, :array_matching => :all) do
    desc 'Export Route Targets (X:Y) [eg. ASN:IP]'
  end

  newproperty(:site_id) do
    desc 'Site ID (unique per peering)'
  end

  newproperty(:bridge) do
    desc 'Bridge to attach VPLS tunnels to'
  end

  newproperty(:bridge_cost) do
    desc 'Port cost on the bridge'
  end

  newproperty(:bridge_horizon) do
    desc 'Port horizon on the bridge'
  end
  
  newproperty(:control_word) do
    desc 'Whether to use control word'
    newvalues(true, false)
  end

  newproperty(:pw_mtu) do
    desc 'MTU for the Pseudowire'
  end
  
  newproperty(:pw_type) do
    desc 'Type of the Pseudowire'
    newvalues(:vpls, 'raw ethernet', 'tagged ethernet')
  end
end

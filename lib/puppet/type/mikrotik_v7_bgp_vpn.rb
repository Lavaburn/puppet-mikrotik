Puppet::Type.newtype(:mikrotik_v7_bgp_vpn) do
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
    desc 'The routing distinguisher'
    isnamevar
  end

  newparam(:vrf) do
    desc 'VRF'
  end
  
  newproperty(:label_allocation_policy) do
    desc 'Label Allocation Policy'
    newvalues('per-prefix', 'per-vrf')
    defaultto 'per-prefix'
  end

  newproperty(:import_route_targets, :array_matching => :all) do
    desc 'The route targets to import into the VRF.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:export_route_targets, :array_matching => :all) do
    desc 'The route targets to export from the VRF.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:import_filter) do
    desc 'The filter applying to the import into the VRF.'
  end
  
  newproperty(:export_filter) do
    desc 'The filter applying to the export from the VRF.'
  end

  newproperty(:redistribute, :array_matching => :all) do
    desc 'The protocols to redistribute into BGP: connected,static,rip,ospf,bgp,vpn,dhcp,fantasy,modem,copy'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

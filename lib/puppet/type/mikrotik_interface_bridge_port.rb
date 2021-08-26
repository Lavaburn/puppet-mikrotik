Puppet::Type.newtype(:mikrotik_interface_bridge_port) do
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
  
  newparam(:interface) do
    desc 'Name of the interface'
    isnamevar
  end

  newproperty(:bridge) do
    desc 'The bridge interface the respective interface is grouped in'
  end

  newproperty(:horizon) do
    desc 'The bridge horizon (ports with equal value do not exchange packets)'
  end
  
  # STP
  newproperty(:priority) do
    desc 'The port priority in STP (or between domains in MSTP). Default: 0x80 (hex)'
  end
  
  newproperty(:path_cost) do
    desc 'The path cost in STP (or between domains in MSTP). Default: 10'
  end
  
  newproperty(:internal_path_cost) do
    desc 'The path cost in the MSTP domain. Default: 10'
  end

  # VLAN 
  newproperty(:pvid) do
    desc 'Port VLAN ID (untagged)'
  end
  
  newproperty(:frame_types) do
    desc 'Allow Frame Types'
    newvalues('admit-all', 'admit-only-untagged-and-priority-tagged', 'admit-only-vlan-tagged')
  end

  newproperty(:ingress_filtering) do
    desc 'Whether to enable ingress filtering'
    newvalues(true, false)
  end

  newproperty(:tag_stacking) do
    desc 'Whether to enable tag stacking'
    newvalues(true, false)
  end
  
  newproperty(:comment) do
    desc 'Comments'
  end

  # Less frequently used options:

  ##  learn -- 
  ##  unknown-unicast-flood -- 
  ##  unknown-multicast-flood -- 
  ##  broadcast-flood -- 
  ##  trusted -- 
  ##  hw -- 
  ##  multicast-router -- 
  ##  fast-leave -- 

  # STP
  ##  edge -- 
  ##  point-to-point -- 
  ##  auto-isolate -- 
  ##  restricted-role -- 
  ##  restricted-tcn -- 
  ##  bpdu-guard -- 
end

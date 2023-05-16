Puppet::Type.newtype(:mikrotik_v7_ospf_instance) do
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
    desc 'OSPF Instance name'
    isnamevar
  end

  newproperty(:comment) do
    desc 'Extra comments'
  end
  
  newproperty(:version) do
    desc 'The OSPF version (2 or 3)'
    newvalues(2, 3)
    defaultto 2
  end

  newproperty(:vrf) do
    desc 'The VRF'
  end

  newproperty(:router_id) do
    desc 'The Router ID.'
  end

  newproperty(:routing_table) do
    desc 'Routing Table to receive and install routes from/to'
  end
  
  newproperty(:originate_default) do
    desc 'Whether to redistribute default routes to OSPF.'
    newvalues('never', 'if-installed', 'always')
  end

  newproperty(:redistribute, :array_matching => :all) do
    desc 'The protocols to redistribute into OSPF: connected,static,rip,ospf,bgp,vpn,dhcp,fantasy,modem,copy'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:out_filter_select) do
    desc 'The output filter select applying on this instance.'
  end
  
  newproperty(:out_filter) do
    desc 'The output filter applying on this instance.'
  end

  newproperty(:in_filter) do
    desc 'The input filter applying on this instance.'
  end

  newproperty(:domain_id) do
    desc 'The Domain ID for this instance.'
  end

  newproperty(:domain_tag) do
    desc 'The Domain Tag for this instance.'
  end
  
  newproperty(:mpls_te_address) do
    desc 'MPLS Traffic Engineering Address'
  end

  newproperty(:mpls_te_area) do
    desc 'MPLS Traffic Engineering Area ID'
  end
end

Puppet::Type.newtype(:mikrotik_ospf_instance) do
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
    desc 'OSPF Instance name'
    isnamevar
  end

  newproperty(:router_id) do
    desc 'The Router ID.'
  end
  
  newproperty(:distribute_default) do
    desc 'Whether to redistribute default routes to OSPF.'
    newvalues('never', 'if-installed-as-type-1', 'if-installed-as-type-2', 'always-as-type-1', 'always-as-type-2')
  end
    
  newproperty(:redistribute_connected) do
    desc 'Whether to redistribute connected routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end

  newproperty(:redistribute_static) do
    desc 'Whether to redistribute static routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end
  
  newproperty(:redistribute_ospf) do
    desc 'Whether to redistribute OSPF routes from other instances to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end
  
  newproperty(:redistribute_bgp) do
    desc 'Whether to redistribute BGP routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end
  
  newproperty(:redistribute_rip) do
    desc 'Whether to redistribute RIP routes to OSPF.'
    newvalues('no', 'as-type-1', 'as-type-2')
  end

  newproperty(:in_filter) do
    desc 'The input filter applying on this instance.'
  end

  newproperty(:out_filter) do
    desc 'The output filter applying on this instance.'
  end

  newproperty(:metric_default) do
    desc 'The metric to use when redistributing default routes on this instance.'
  end

  newproperty(:metric_connected) do
    desc 'The metric to use when redistributing connected routes on this instance.'
  end

  newproperty(:metric_static) do
    desc 'The metric to use when redistributing static routes on this instance.'
  end

  newproperty(:metric_bgp) do
    desc 'The metric to use when redistributing BGP routes on this instance.'
  end

  newproperty(:metric_ospf) do
    desc 'The metric to use when redistributing OSPF routes from other instances on this instance.'
  end
  
  newproperty(:metric_rip) do
    desc 'The metric to use when redistributing RIP routes on this instance.'
  end

  newproperty(:mpls_te_area) do
    desc 'MPLS Traffic Engineering Area ID'
  end
  
  newproperty(:mpls_te_router_id) do
    desc 'MPLS Traffic Engineering Router ID'
  end
  
  newproperty(:routing_table) do
    desc 'Routing Table to receive and install routes from/to'
  end
end

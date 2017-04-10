Puppet::Type.newtype(:mikrotik_mpls_ldp) do
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
    desc 'Name should be -ldp-'
    isnamevar
  end

  newproperty(:lsr_id) do
    desc 'MPLS LSR ID'
  end

  newproperty(:transport_address) do
    desc 'Transport address for LDP'
  end

  newproperty(:path_vector_limit) do
    desc 'Path Vector Limit'
  end

  newproperty(:hop_limit) do
    desc 'Hop Limit'
  end

  newproperty(:loop_detect) do
    desc 'Whether to enable loop detect.'
  end

  newproperty(:use_explicit_null) do
    desc 'Whether to enable use of explicit null.'
  end

  newproperty(:distribute_for_default_route) do
    desc 'Whether to enable distribution of default route.'
  end
end

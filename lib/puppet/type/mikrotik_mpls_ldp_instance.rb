Puppet::Type.newtype(:mikrotik_mpls_ldp_instance) do
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
    desc 'Instance name'
    isnamevar
  end

  newproperty(:lsr_id) do
    desc 'MPLS LSR ID'
  end

  newproperty(:transport_addresses, :array_matching => :all) do
    desc 'Transport address for LDP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
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

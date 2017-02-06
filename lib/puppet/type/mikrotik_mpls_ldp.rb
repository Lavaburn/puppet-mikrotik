Puppet::Type.newtype(:mikrotik_mpls_ldp) do
  apply_to_device

  ensurable do
    defaultto :disabled
    
    newvalue(:enabled) do
      provider.setState(:enabled)      
    end

    newvalue(:disabled) do
      provider.setState(:disabled)
    end

    def retrieve
      provider.getState
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

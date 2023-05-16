Puppet::Type.newtype(:mikrotik_v7_bgp_template) do
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
  
  # General
  newparam(:name) do
    desc 'BGP Template name'
    isnamevar
  end

  newproperty(:as) do
    desc 'The Autonomous System Number (ASN).'
  end

  newproperty(:address_families, :array_matching => :all) do
    desc 'The address families to exchange routing information for [ip, ipv6, l2vpn, vpn4, l2vpn-cisco].'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:router_id) do
    desc 'The Router ID'
  end

  newproperty(:multihop) do
    desc 'Whether to allow multiple hops between peers.'
    newvalues(true, false)
  end

  newproperty(:templates, :array_matching => :all) do
    desc 'The BGP templates to inherit'
  end

  # Extra
  newproperty(:hold_time) do
    desc 'The time (seconds) to hold the session up once keepalive exceeded.'
  end

  newproperty(:keepalive_time) do
    desc 'The time (seconds) to keep the session alive.'
  end

  newproperty(:use_bfd) do
    desc 'Whether to use BFD to break a faulty session faster.'
    newvalues(true, false)
  end

  newproperty(:routing_table) do
    desc 'The Routing table to use'
  end
  
  newproperty(:vrf) do
    desc 'The VRF to use'
  end

  newproperty(:cluster_id) do
    desc 'The Cluster ID'
  end

  newproperty(:disable_client_to_client_relection) do    # no-client-to-client-reflection
    desc 'Whether to act as a Reflector for this peer.'
    newvalues(true, false)
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

  newproperty(:default_originate) do
    desc 'Whether to redistribute default routes to BGP.'
    newvalues('never', 'if-installed', 'always')
  end
  
  newproperty(:no_early_cut) do
    desc 'Whether to disable Early Cut ?'
    newvalues(true, false)
  end
  
  newproperty(:keep_sent_attributes) do
    desc 'Whether to keep sent attributes.'
    newvalues(true, false)
  end
  
  newproperty(:input_affinity) do
    desc 'The input affinity'
  end
  
  newproperty(:output_affinity) do
    desc 'The output affinity'
  end

  # Attributes
  newproperty(:nexthop_choice) do
    desc 'Whether to change nexthop on advertisements.'
    newvalues('default', 'force-self', 'propagate')
  end
  
  newproperty(:as_override) do
    desc 'Whether to replace peer ASN with own ASN.'
    newvalues(true, false)
  end
  
  newproperty(:default_prepend) do
    desc 'The default AS prepend length'
  end
  
  newproperty(:add_path_out) do
    desc 'Add Path Out (?)'
    newvalues(:none, :all)
  end
  
  newproperty(:allow_as_in) do
    desc 'The maximum number of times my own ASN can appear in the AS Path.'
  end

  newproperty(:ignore_as_path_length) do
    desc 'Whether to ignore AS Path length'
    newvalues(true, false)
  end 
    
  newproperty(:remove_private_as) do
    desc 'Whether to remove private ASNs when advertising to peer.'
    newvalues(true, false)
  end

  newproperty(:cisco_vpls_nlri_len_fmt) do
    desc 'The Cisco VPLS NLRI Length Format: auto-bits, auto-bytes, bits, bytes'
    newvalues('auto-bits', 'auto-bytes', 'bits', 'bytes')
  end
  
  # Filter
  newproperty(:input_filter) do
    desc 'The input filter'
  end

  newproperty(:input_accept_nlri) do
    desc 'The address list to accept inbound (NLRI)'
  end
  
  newproperty(:input_accept_communities) do
    desc 'The input filter to accept communities'
  end
  
  newproperty(:input_accept_ext_communities) do
    desc 'The input filter to accept extended communities'
  end
  
  newproperty(:input_accept_large_communities) do
    desc 'The input filter to accept large communities'
  end
  
  newproperty(:input_accept_unknown) do
    desc 'The input filter to accept unknown (?)'
  end
  
  newproperty(:output_filter) do
    desc 'The output filter'
  end

  newproperty(:output_filter_select) do
    desc 'The output filter Selection Policy'
  end

  newproperty(:output_network) do
    desc 'The address list to accept outbound (networks)'
  end
  
  newproperty(:comment) do
    desc 'Comment about the template.'
  end
end

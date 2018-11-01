Puppet::Type.newtype(:mikrotik_bgp_peer) do
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
    desc 'BGP Peer name'
    isnamevar
  end

  newproperty(:instance) do
    desc 'The BGP Instance this peer belongs to.'
  end

  newproperty(:peer_address) do
    desc 'The Peer Remote Address (IP).'
  end

  newproperty(:peer_port) do
    desc 'TCP port to connect to.'
  end

  newproperty(:peer_as) do
    desc 'The Peer Autonomous System Number (ASN).'
  end

  newproperty(:tcp_md5_key) do
    desc 'The MD5 hash for securing the session.'
  end

  newproperty(:nexthop_choice) do
    desc 'Whether to change nexthop on advertisements.'
    newvalues('default', 'force-self', 'propagate')
  end

  newproperty(:multihop) do
    desc 'Whether to allow multiple hops between peers.'
    newvalues(true, false)
  end

  newproperty(:route_reflect) do
    desc 'Whether to act as a Reflector for this peer.'
    newvalues(true, false)
  end

  newproperty(:hold_time) do
    desc 'The time (seconds) to hold the session up once keepalive exceeded.'
  end

  newproperty(:keepalive_time) do
    desc 'The time (seconds) to keep the session alive.'
  end

  newproperty(:ttl) do
    desc 'The max. number of hop0 (TTL) to reach the peer in.'
  end

  newproperty(:max_prefix_limit) do
    desc 'The maximum number of prefixes to accept from the peer.'
  end

  newproperty(:max_prefix_restart_time) do
    desc 'Minimum time after which peer can reestablish session if max prefix limit was exceeded.'
  end

  newproperty(:in_filter) do
    desc 'The input filter that applies to this peer.'
  end

  newproperty(:out_filter) do
    desc 'The output filter that applies to this peer.'
  end

  newproperty(:allow_as_in) do
    desc 'The maximum number of times my own ASN can appear in the AS Path.'
  end

  newproperty(:remove_private_as) do
    desc 'Whether to remove private ASNs when advertising to peer.'
    newvalues(true, false)
  end

  newproperty(:as_override) do
    desc 'Whether to replace peer ASN with own ASN.'
    newvalues(true, false)
  end

  newproperty(:default_originate) do
    desc 'Specifies how to distribute default route.'
    newvalues('never', 'if-installed', 'always')
  end

  newproperty(:passive) do
    desc 'Do not connect to the peer, only accept incoming connection.'
    newvalues(true, false)
  end

  newproperty(:use_bfd) do
    desc 'Whether to use BFD to break a faulty session faster.'
    newvalues(true, false)
  end

  newproperty(:address_families, :array_matching => :all) do
    desc 'The address families to exchange routing information for [ip, ipv6, l2vpn, vpn4, l2vpn-cisco].'
  end

  newproperty(:source) do
    desc 'The Source IP/Interface that connections should be seen from.'
  end

  newproperty(:comment) do
    desc 'Comment about the peer.'
  end
end

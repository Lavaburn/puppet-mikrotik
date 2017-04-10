Puppet::Type.newtype(:mikrotik_bgp_peer) do
  ensurable do
    defaultvalues
    defaultto :present
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

  newproperty(:peer_as) do
    desc 'The Peer Autonomous System Number (ASN).'
  end

  newproperty(:source) do
    desc 'The Source IP/Interface that connections should be seen from.'
  end
  
  newproperty(:out_filter) do
    desc 'The output filter that applies to this peer.'
  end

  newproperty(:in_filter) do
    desc 'The input filter that applies to this peer.'
  end

  newproperty(:route_reflect) do
    desc 'Whether to act as a Reflector for this peer.'
    newvalues(true, false)
  end
  
  newproperty(:default_originate) do
    desc 'Whether to originate routing table this instance belongs to.'
    newvalues('no', 'if-installed', 'always')
  end
     
  # multihop    
  # tcp-md5-key   
  
  # keepalive-time   
  # hold-time             
  # use-bfd   
  
  # address-families    
  # allow-as-in      
  # as-override              
  # nexthop-choice     
  # ttl                   
  # passive         
  # max-prefix-limit         
  # remote-port
  # max-prefix-restart-time  
  # remove-private-as
end

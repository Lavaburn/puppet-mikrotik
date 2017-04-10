Puppet::Type.newtype(:mikrotik_firewall_rule) do
  ensurable do
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

    defaultto :present
    
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
    desc 'The unique identifier for the rule'
    isnamevar
  end
      
  newparam(:sequence) do
    desc 'Sequence of the rule in the chain'
  end
  
  newparam(:table) do
    desc 'The table to which the rule applies (filter,nat,mangle)'
  end
  
  # General
  newproperty(:chain) do
    desc 'The chain to which the rule applies (input,output,filter,src-nat,...)'
  end
  
  newproperty(:src_address) do  # src-address
    desc 'Source address with mask'
  end
  
  newproperty(:dst_address) do  # dst-address
    desc 'Destination address with mask'
  end

  newproperty(:protocol) do  # protocol
    desc 'Protocol name or number'
  end

  newproperty(:src_port) do  # src-port
    desc 'Source-port number'
  end

  newproperty(:dst_port) do  # dst-port
    desc 'Destination port number or range'
  end

  newproperty(:port) do  # port
    desc 'Source Or Destination port number or range'
  end
  
  newproperty(:p2p) do  # p2p
    desc 'P2P program to match'
  end  

  newproperty(:in_interface) do  # in-interface
    desc 'Interface the packet has entered the router through'
  end

  newproperty(:out_interface) do  # out-interface
    desc 'Interface the packet has leaved the router through'
  end

  newproperty(:in_interface_list) do  # in-interface-list
    desc 'Interface List the packet has entered the router through'
  end

  newproperty(:out_interface_list) do  # out-interface-list
    desc 'Interface List the packet has leaved the router through'
  end

  newproperty(:packet_mark) do  # packet-mark
    desc 'Matches packets marked via mangle facility with particular packet mark'
  end

  newproperty(:connection_mark) do  # connection-mark
    desc 'Matches packets marked via mangle facility with particular connection mark'
  end

  newproperty(:routing_mark) do  # routing-mark
    desc 'Matches packets marked by mangle facility with particular routing mark'
  end

  newproperty(:routing_table) do  # routing-table
    desc 'Matches packets on particular routing table'
  end

  newproperty(:connection_type) do  # connection-type
    desc 'Match packets with given connection type'
  end

  newproperty(:connection_state) do  # connection-state
    desc 'Interprets the connection tracking analysis data for a particular packet'
  end

  newproperty(:connection_nat_state) do  # connection-nat-state
    desc 'Interprets the NAT connection tracking analysis data for a particular packet'
  end

  # Advanced
  newproperty(:src_address_list) do  # src-address-list
    desc 'Matches source address of a packet against user-defined address list'
  end
  
  newproperty(:dst_address_list) do  # dst-address-list
    desc 'Destination address list name in which packet place'
  end
  
  newproperty(:layer7_protocol) do  # layer7-protocol
    desc 'TODO'
  end
  
  newproperty(:content) do  # content
    desc 'The text packets should contain in order to match the rule'
  end
  
  newproperty(:connection_bytes) do  # connection-bytes
    desc 'Match packets with given bytes or byte range'
  end
  
  newproperty(:connection_rate) do  # connection-rate
    desc 'TODO'
  end
  
  newproperty(:per_connection_classifier) do  # per-connection-classifier
    desc 'TODO'
  end
  
  newproperty(:src_mac_address) do  # src-mac-address
    desc 'Source MAC address'
  end
  
  newproperty(:in_bridge_port) do  # in-bridge-port
    desc 'TODO'
  end
  
  newproperty(:out_bridge_port) do  # out-bridge-port
    desc 'Matches the bridge port physical output device added to a bridge device'
  end
  
  newproperty(:in_bridge_port_list) do  # in-bridge-port-list
    desc 'TODO'
  end
  
  newproperty(:out_bridge_port_list) do  # out-bridge-port-list
    desc 'TODO'
  end
  
  newproperty(:ipsec_policy) do  # ipsec-policy
    desc 'TODO'
  end
  
  newproperty(:ingress_priority) do  # ingress-priority
    desc 'TODO'
  end
  
  newproperty(:priority) do  # priority
    desc 'TODO'
  end
  
  newproperty(:dscp) do  # dscp
    desc 'TODO'
  end
  
  newproperty(:tcp_mss) do  # tcp-mss
    desc 'TCP Maximum Segment Size value'
  end
  
  newproperty(:packet_size) do  # packet-size
    desc 'Packet size or range in bytes'
  end
  
  newproperty(:random) do  # random
    desc 'Match packets randomly with given propability'
  end
  
  newproperty(:tcp_flags) do  # tcp-flags
    desc 'TCP flags to match'
  end
  
  newproperty(:ipv4_options) do  # ipv4-options
    desc 'Match ipv4 header options'
  end
  
  newproperty(:ttl) do  # ttl
    desc 'TODO'
  end
  
  # Extra  
  newproperty(:connection_limit) do  # connection-limit
    desc 'Restrict connection limit per address or address block'
  end
  
  newproperty(:limit) do  # limit
    desc 'Setup burst, how many times to use it in during time interval measured in seconds'
  end
  
  newproperty(:dst_limit) do  # dst-limit
    desc 'Packet limitation per time with burst to dst-address, dst-port or src-address'
  end
  
  newproperty(:nth) do  # nth
    desc 'Match nth packets received by the rule'
  end
  
  newproperty(:time) do  # time
    desc 'Packet arrival time and date or locally generated packets departure time and date'
  end
  
  newproperty(:src_address_type) do  # src-address-type
    desc 'Source IP address type'
  end
  
  newproperty(:dst_address_type) do  # dst-address-type
    desc 'Destination address type'
  end
  
  newproperty(:psd) do  # psd
    desc 'Detect TCP un UDP scans'
  end
  
  newproperty(:hotspot) do  # hotspot
    desc 'Matches packets received from clients against various Hot-Spot'
  end
  
  newproperty(:fragment) do  # fragment
    desc 'TODO'
  end
      
  # Action    
  newproperty(:action) do
    desc 'Action to undertake if the packet matches the rule'
  end
  
  newproperty(:log) do  # log
    desc 'TODO'
  end
  
  newproperty(:log_prefix) do  # log-prefix
    desc 'Creates all logs with specific prefix'
  end
  
  newproperty(:jump_target) do  # jump-target
    desc 'Name of the target chain, if the action=jump is used'
  end

  newproperty(:address_list) do  # address-list
    desc 'Address list in which marked address put'
  end
  
  newproperty(:address_list_timeout) do  # address-list-timeout
    desc 'Time interval after which address remove from address list'
  end
  
  newproperty(:reject_with) do  # reject-with
    desc 'Alters the reply packet of reject action'
  end
  
  newproperty(:to_addresses) do  # to-addresses
    desc 'Address or address range to replace original address of an IP packet with'
  end
  
  newproperty(:to_ports) do  # to-ports
    desc 'Port or port range to replace original port of an IP packet with'
  end
  
  newproperty(:new_connection_mark) do  # new-connection-mark
    desc 'Specify the new value of the connection mark to be used in conjunction with action=mark-connection'
  end
  
  newproperty(:new_dscp) do  # new-dscp
    desc 'TODO'
  end
  
  newproperty(:new_mss) do  # new-mss
    desc 'Specify MSS value to be used in conjunction with action=change-mss'
  end
  
  newproperty(:new_packet_mark) do  # new-packet-mark
    desc 'Specify the new value of the packet mark to be used in conjunction with action=mark-packet'
  end
  
  newproperty(:new_priority) do  # new-priority
    desc 'TODO'
  end
  
  newproperty(:new_routing_mark) do  # new-routing-mark
    desc 'Specify the new value of the routing mark used in conjunction with action=mark-routing'
  end
  
  newproperty(:new_ttl) do  # new-ttl
    desc 'Specify the new TTL field value used in conjunction with action=change-ttl'
  end
  
  newproperty(:route_dst) do  # route-dst
    desc 'TODO'
  end
  
  newproperty(:sniff_id) do  # sniff-id
    desc 'TODO'
  end
  
  newproperty(:sniff_target) do  # sniff-target
    desc 'TODO'
  end
  
  newproperty(:sniff_target_port) do  # sniff-target-port
    desc 'TODO'
  end
end

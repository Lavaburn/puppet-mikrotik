require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_firewall_rule).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []

    filter_rules = get_all("/ip/firewall/filter")
    filter_rules.each do |rule|
      object = firewallRule(rule, 'filter', filter_rules)
      if object != nil
        instances << object
      end
    end

    nat_rules = get_all("/ip/firewall/nat")
    nat_rules.each do |rule|
      object = firewallRule(rule, 'nat', nat_rules)
      if object != nil
        instances << object
      end
    end

    mangle_rules = get_all("/ip/firewall/mangle")
    mangle_rules.each do |rule|
      object = firewallRule(rule, 'mangle', mangle_rules)
      if object != nil
        instances << object
      end      
    end

    instances
  end
  
  def self.firewallRule(rule, table, all_rules)
    if rule['comment'] != nil  
      if rule['disabled'] == 'true'
        state = :disabled
      else
        state = :enabled
      end

      chain_order = getChainOrder(rule['.id'], rule['chain'], all_rules)

      new(
        :ensure                    => :present,
        :state                     => state,
        :name                      => rule['comment'],
        :table                     => table,
        # General
        :chain                     => rule['chain'],
        :chain_order               => chain_order.to_s,
        :src_address               => rule['src-address'],
        :dst_address               => rule['dst-address'],
        :protocol                  => rule['protocol'],
        :src_port                  => rule['src-port'],
        :dst_port                  => rule['dst-port'],
        :port                      => rule['port'],
        :p2p                       => rule['p2p'],
        :in_interface              => rule['in-interface'],
        :out_interface             => rule['out-interface'],
        :in_interface_list         => rule['in-interface-list'],
        :out_interface_list        => rule['out-interface-list'],
        :packet_mark               => rule['packet-mark'],
        :connection_mark           => rule['connection-mark'],
        :routing_mark              => rule['routing-mark'],
        :routing_table             => rule['routing-table'],
        :connection_type           => rule['connection-type'],
        :connection_state          => rule['connection-state'],
        :connection_nat_state      => rule['connection-nat-state'],
        # Advanced
        :src_address_list          => rule['src-address-list'],
        :dst_address_list          => rule['dst-address-list'],
        :layer7_protocol           => rule['layer7-protocol'],
        :content                   => rule['content'],
        :connection_bytes          => rule['connection-bytes'],
        :connection_rate           => rule['connection-rate'],
        :per_connection_classifier => rule['per-connection-classifier'],
        :src_mac_address           => rule['src-mac-address'],
        :in_bridge_port            => rule['in-bridge-port'],
        :out_bridge_port           => rule['out-bridge-port'],
        :in_bridge_port_list       => rule['in-bridge-port-list'],
        :out_bridge_port_list      => rule['out-bridge-port-list'],
        :ipsec_policy              => rule['ipsec-policy'],
        :ingress_priority          => rule['ingress-priority'],
        :priority                  => rule['priority'],
        :dscp                      => rule['dscp'],
        :tcp_mss                   => rule['tcp-mss'],
        :packet_size               => rule['packet-size'],
        :random                    => rule['random'],
        :tcp_flags                 => rule['tcp-flags'],      
        :ipv4_options              => rule['ipv4-options'],
        :ttl                       => rule['ttl'],
        # Extra  
        :connection_limit          => rule['connection-limit'],
        :limit                     => rule['limit'],
        :dst_limit                 => rule['dst-limit'],
        :nth                       => rule['nth'],
        :time                      => rule['time'],
        :src_address_type          => rule['src-address-type'],
        :dst_address_type          => rule['dst-address-type'],
        :psd                       => rule['psd'],
        :hotspot                   => rule['hotspot'],
        :fragment                  => rule['fragment'],      
        # Action    
        :action                    => rule['action'],
        :log                       => rule['log'],
        :log_prefix                => rule['log-prefix'],
        :jump_target               => rule['jump-target'],
        :address_list              => rule['address-list'],
        :address_list_timeout      => rule['address-list-timeout'],
        :reject_with               => rule['reject-with'],
        :to_addresses              => rule['to-addresses'],
        :to_ports                  => rule['to-ports'],
        :new_connection_mark       => rule['new-connection-mark'],
        :new_dscp                  => rule['new-dscp'],
        :new_mss                   => rule['new-mss'],
        :new_packet_mark           => rule['new-packet-mark'],
        :new_priority              => rule['new-priority'],
        :new_routing_mark          => rule['new-routing-mark'],
        :new_ttl                   => rule['new-ttl'],
        :route_dst                 => rule['route-dst'],
        :sniff_id                  => rule['sniff-id'],
        :sniff_target              => rule['sniff-target'],
        :sniff_target_port         => rule['sniff-target-port']
      )
    end
  end

  def flush
    Puppet.debug("Flushing Firewall Rule #{resource[:name]}")

    if @property_flush[:ensure] == :absent
      if @property_hash[:table].nil?
        raise "Table is always a required parameter."
      end
      table = @property_hash[:table]
    else
      if resource[:table].nil? or resource[:chain].nil?
        raise "Table and Chain are required parameters."
      end
      table = resource[:table]
    end
    
    params = {}
        
    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end

    if !resource[:chain_order].nil?
      table_rules = Puppet::Provider::Mikrotik_Api::get_all("/ip/firewall/#{table}")
      ids = self.class.getChainIds(resource[:chain], table_rules)
      
      if @property_flush[:ensure] == :present
        unless resource[:chain_order] > ids.length
          rule_id_after = ids[resource[:chain_order].to_i - 1]# index starts at 0, order starts at 1
          params["place-before"] = rule_id_after
        end
      end
    end

    params["comment"] = resource[:name]
    # General
    params["chain"] = resource[:chain] if ! resource[:chain].nil?   
    params["src-address"] = resource[:src_address] if ! resource[:src_address].nil?   
    params["dst-address"] = resource[:dst_address] if ! resource[:dst_address].nil?   
    params["protocol"] = resource[:protocol] if ! resource[:protocol].nil?  
    params["src-port"] = resource[:src_port] if ! resource[:src_port].nil?  
    params["dst-port"] = resource[:dst_port] if ! resource[:dst_port].nil?  
    params["port"] = resource[:port] if ! resource[:port].nil?  
    params["p2p"] = resource[:p2p] if ! resource[:p2p].nil?        
    params["in-interface"] = resource[:in_interface] if ! resource[:in_interface].nil?  
    params["out-interface"] = resource[:out_interface] if ! resource[:out_interface].nil?  
    params["in-interface-list"] = resource[:in_interface_list] if ! resource[:in_interface_list].nil?  
    params["out-interface-list"] = resource[:out_interface_list] if ! resource[:out_interface_list].nil?  
    params["packet-mark"] = resource[:packet_mark] if ! resource[:packet_mark].nil?  
    params["connection-mark"] = resource[:connection_mark] if ! resource[:connection_mark].nil?  
    params["routing-mark"] = resource[:routing_mark] if ! resource[:routing_mark].nil?  
    params["routing-table"] = resource[:routing_table] if ! resource[:routing_table].nil?  
    params["connection-type"] = resource[:connection_type] if ! resource[:connection_type].nil?  
    params["connection-state"] = resource[:connection_state] if ! resource[:connection_state].nil?  
    params["connection-nat-state"] = resource[:connection_nat_state] if ! resource[:connection_nat_state].nil?
    # Advanced
    params["src-address-list"] = resource[:src_address_list] if ! resource[:src_address_list].nil?
    params["dst-address-list"] = resource[:dst_address_list] if ! resource[:dst_address_list].nil?
    params["layer7-protocol"] = resource[:layer7_protocol] if ! resource[:layer7_protocol].nil?
    params["content"] = resource[:content] if ! resource[:content].nil?
    params["connection-bytes"] = resource[:connection_bytes] if ! resource[:connection_bytes].nil?
    params["connection-rate"] = resource[:connection_rate] if ! resource[:connection_rate].nil?
    params["per-connection-classifier"] = resource[:per_connection_classifier] if ! resource[:per_connection_classifier].nil?
    params["src-mac-address"] = resource[:src_mac_address] if ! resource[:src_mac_address].nil?
    params["in-bridge-port"] = resource[:in_bridge_port] if ! resource[:in_bridge_port].nil?
    params["out-bridge-port"] = resource[:out_bridge_port] if ! resource[:out_bridge_port].nil?
    params["in-bridge-port-list"] = resource[:in_bridge_port_list] if ! resource[:in_bridge_port_list].nil?
    params["out-bridge-port-list"] = resource[:out_bridge_port_list] if ! resource[:out_bridge_port_list].nil?
    params["ipsec-policy"] = resource[:ipsec_policy] if ! resource[:ipsec_policy].nil?
    params["ingress-priority"] = resource[:ingress_priority] if ! resource[:ingress_priority].nil?
    params["priority"] = resource[:priority] if ! resource[:priority].nil?
    params["dscp"] = resource[:dscp] if ! resource[:dscp].nil?
    params["tcp-mss"] = resource[:tcp_mss] if ! resource[:tcp_mss].nil?
    params["packet-size"] = resource[:packet_size] if ! resource[:packet_size].nil?
    params["random"] = resource[:random] if ! resource[:random].nil?
    params["tcp-flags"] = resource[:tcp_flags] if ! resource[:tcp_flags].nil?  
    params["ipv4-options"] = resource[:ipv4_options] if ! resource[:ipv4_options].nil?
    params["ttl"] = resource[:ttl] if ! resource[:ttl].nil?
    # Extra
    params["connection-limit"] = resource[:connection_limit] if ! resource[:connection_limit].nil?
    params["limit"] = resource[:limit] if ! resource[:limit].nil?
    params["dst-limit"] = resource[:dst_limit] if ! resource[:dst_limit].nil?
    params["nth"] = resource[:nth] if ! resource[:nth].nil?
    params["time"] = resource[:time] if ! resource[:time].nil?
    params["src-address-type"] = resource[:src_address_type] if ! resource[:src_address_type].nil?
    params["dst-address-type"] = resource[:dst_address_type] if ! resource[:dst_address_type].nil?
    params["psd"] = resource[:psd] if ! resource[:psd].nil?
    params["hotspot"] = resource[:hotspot] if ! resource[:hotspot].nil?
    params["fragment"] = resource[:fragment] if ! resource[:fragment].nil?  
    # Action
    params["action"] = resource[:action] if ! resource[:action].nil?   
    params["log"] = resource[:log] if ! resource[:log].nil?
    params["log-prefix"] = resource[:log_prefix] if ! resource[:log_prefix].nil?
    params["jump-target"] = resource[:jump_target] if ! resource[:jump_target].nil?
    params["address-list"] = resource[:address_list] if ! resource[:address_list].nil?
    params["address-list-timeout"] = resource[:address_list_timeout] if ! resource[:address_list_timeout].nil?
    params["reject-with"] = resource[:reject_with] if ! resource[:reject_with].nil?
    params["to-addresses"] = resource[:to_addresses] if ! resource[:to_addresses].nil?
    params["to-ports"] = resource[:to_ports] if ! resource[:to_ports].nil?
    params["new-connection-mark"] = resource[:new_connection_mark] if ! resource[:new_connection_mark].nil?
    params["new-dscp"] = resource[:new_dscp] if ! resource[:new_dscp].nil?
    params["new-mss"] = resource[:new_mss] if ! resource[:new_mss].nil?
    params["new-packet-mark"] = resource[:new_packet_mark] if ! resource[:new_packet_mark].nil?
    params["new-priority"] = resource[:new_priority] if ! resource[:new_priority].nil?      
    params["new-routing-mark"] = resource[:new_routing_mark] if ! resource[:new_routing_mark].nil?
    params["new-ttl"] = resource[:new_ttl] if ! resource[:new_ttl].nil?
    params["route-dst"] = resource[:route_dst] if ! resource[:route_dst].nil?
    params["sniff-id"] = resource[:sniff_id] if ! resource[:sniff_id].nil?
    params["sniff-target"] = resource[:sniff_target] if ! resource[:sniff_target].nil?
    params["sniff-target-port"] = resource[:sniff_target_port] if ! resource[:sniff_target_port].nil?
      
    lookup = { "comment" => resource[:name] }
    
    Puppet.debug("Rule: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/firewall/#{table}", params, lookup)
      
    if !resource[:chain_order].nil?
      if @property_flush.empty?
        id_list = Puppet::Provider::Mikrotik_Api::lookup_id("/ip/firewall/#{table}", lookup)
        id_list.each do |id|
          chain_order = self.class.getChainOrder(id, resource[:chain], table_rules)
          if resource[:chain_order].to_i != chain_order
            self.class.moveRule(id, table, resource[:chain], chain_order, resource[:chain_order].to_i, table_rules)
          end
        end
      end
    end
  end
    
  def self.getChainOrder(lookup_id, lookup_chain, table_rules)    
    ids = getChainIds(lookup_chain, table_rules)
    
    chain_order = 1
    ids.each do |id|
      if id == lookup_id
         return chain_order
      end        
     
      chain_order = chain_order + 1
    end
  end
  
  def self.getChainIds(lookup_chain, table_rules)
    ids = table_rules.collect do |rule|
      if rule['chain'] == lookup_chain
        rule['.id']
      end
    end
    
    ids.compact
  end
    
  def self.moveRule(rule_id, table, lookup_chain, old_chain_order, new_chain_order, table_rules)
    Puppet.debug("Moving rule #{rule_id} from position #{old_chain_order} to position #{new_chain_order} in chain #{lookup_chain} on table #{table}.")
    
    if new_chain_order == old_chain_order
      return
    end
  
    if new_chain_order > old_chain_order
      lookup_order = new_chain_order + 1
    else
      lookup_order = new_chain_order
    end
  
    destination = nil
    chain_pos = 0
  
    table_rules.each do |rule|
      if rule['chain'] == lookup_chain
        chain_pos = chain_pos + 1         
      end
      
      if chain_pos == new_chain_order
        destination = rule['.id']  
      end
      
      if chain_pos == lookup_order
        destination = rule['.id']   
        break
      end
    end
  
    if rule_id == destination
      return
    end
  
    move_params = {}
    move_params["numbers"] = rule_id
    move_params["destination"] = destination if destination != nil
    result = Puppet::Provider::Mikrotik_Api::move("/ip/firewall/#{table}", move_params)
  end
end
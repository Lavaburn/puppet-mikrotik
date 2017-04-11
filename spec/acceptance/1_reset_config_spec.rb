require 'spec_helper_acceptance'

describe 'reset configuration' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "first run" do  
    before(:all) do
      @pp = <<-EOS
        contain ::mikrotik
      EOS
    end
    
    it 'should run manifest idempotently' do
      @result = apply_manifests(agents, @pp)
      
      @result = apply_manifests(agents, @pp)
      expect(@result.exit_code).to eq(0)
    end
  
    it 'should reset configuration idempotently' do    
      site_pp = <<-EOS
        mikrotik_dns { 'dns':
          servers               => ['8.8.8.8','8.8.4.4'],
          allow_remote_requests => true,
        }

        mikrotik_firewall_rule { 'Puppet Test 1':
          ensure   => 'absent',
        }
        mikrotik_firewall_rule { 'Puppet Test 2':
          ensure   => 'absent',
        }
        mikrotik_firewall_rule { 'Puppet Test 3':
          ensure   => 'absent',
        }

        mikrotik_address_list { 'MT_TEST_LIST':
          ensure => 'absent',
        }    
            
        mikrotik_ip_service { 'telnet':
          ensure => 'disabled',
        }
        mikrotik_ip_service { 'api-ssl':
          ensure => 'enabled',
        }
        mikrotik_ip_service { 'www':
          addresses => [],  # TODO - DOES NOT WORK?
        }
        mikrotik_ip_service { 'ftp':
          port => 21,
        }  
              
        mikrotik_snmp { 'snmp':
          ensure          => disabled,
          contact         => "jubanoc@rcswimax.com",
          location        => "South Sudan",
          trap_version    => 1,
          trap_community  => "public",
          trap_generators => [],
          trap_targets    => [],
        }
        mikrotik_snmp_community { 'test_ro':
          ensure     => absent,
        }
        mikrotik_snmp_community { 'test_rw':
          ensure     => absent,
        }
        
        mikrotik_logging_action { 'myRemote':
          ensure => absent
        }
        mikrotik_logging_rule { 'info,!dhcp_myRemote':
          ensure => absent,
          topics => ['info','!dhcp'],
          action => 'myRemote',
        }
          
        mikrotik_radius_server { 'auth-backup':
          ensure => absent,
        }
        
        mikrotik_user { 'testuser1':
          ensure => absent,
        }
        
        mikrotik_user_group { 'admin1':
          ensure => absent,
        }
             
        mikrotik_user_group { 'admin2':
          ensure => absent,
        }
        
        mikrotik_user_aaa { 'aaa':
          use_radius     => false,
          accounting     => false,
          interim_update => '1m',
          default_group  => 'read',
          exclude_groups => []
        }

        # TODO
        mikrotik_user_sshkey { 'testuser1':
          ensure => absent,
        }
        
        # system spec
        mikrotik_system { 'system':
          identity      => 'mikrotik',
          timezone      => 'Europe/Brussels',
          ntp_enabled   => false,
          ntp_primary   => '193.190.147.153',
          ntp_secondary => '195.200.224.66',
        }   
         
        mikrotik_script { 'script1': 
          ensure => absent,
        }
      
        mikrotik_schedule { 'daily_run_script1': 
          ensure => absent,
        }
         
        #
        mikrotik_ip_settings { 'ip':
          rp_filter => 'no',
        }
        
        mikrotik_tool_email { 'email':
          server       => '127.0.0.1',
          from_address => 'jubanoc@rcswimax.com',
        }
        
        mikrotik_graph_interface { 'all':
          ensure => absent,
        }
        
        mikrotik_graph_resource { 'resource':
          ensure => absent,
        }
        
        mikrotik_graph_queue { 'all':
          ensure => absent,
        }
          
        mikrotik_bgp_instance { 'RCS':
          ensure => absent,
        }
        
        mikrotik_bgp_peer { 'dude1':
          ensure => absent,
        }
        
        mikrotik_ospf_interface { 'ether1':
          ensure => absent,        
        }
        
        mikrotik_ospf_network { '105.235.209.44/32':
          ensure => absent,        
        }
          
        mikrotik_ospf_area { 'BORDER3':
          ensure => absent,        
        }
        
        mikrotik_ospf_instance { 'RCS':
          ensure => absent,        
        }

        # ppp spec 
        mikrotik_ppp_aaa { 'aaa':
          use_radius     => false,
          accounting     => false,
          interim_update => '1m',
        }

        mikrotik_ppp_profile { 'profile1':
          ensure => absent,
        }

        mikrotik_ppp_profile { 'profile2':
          ensure => absent,
        }

        # interface_spec
        mikrotik_interface_vrrp { 'br0_vip':
          ensure => absent,        
        }
  
        mikrotik_interface_bridge_port { 'VLAN_4001':
          ensure => absent,
        }
        
        mikrotik_interface_bridge { 'br0':
          ensure => absent,
        }
        
        mikrotik_interface_bridge { 'br1':
          ensure => absent,
        }
        
        mikrotik_interface_bond { 'ip_tnl_bond':
          ensure => absent,
        }
  
        mikrotik_interface_eoip { 'ip_tnl_01':
          ensure => absent,
        }
        
        mikrotik_interface_eoip { 'ip_tnl_02':
          ensure => absent,
        }
        
        mikrotik_interface_vlan { 'VLAN_4001':
          ensure => absent,
        }

        mikrotik_interface_ethernet { 'ether1': 
          alias => 'ether1',
        }
      
        mikrotik_interface_list { 'interface_list_1':
          ensure => 'absent',
        }
        
        mikrotik_ppp_server { 'pptp':
          ensure => 'disabled',
        }
              
        mikrotik_ppp_server { 'l2tp':
          ensure => 'disabled',
        }

        mikrotik_ppp_secret  { 'ppp_user1':
          ensure => 'absent',
        }
      
        mikrotik_ppp_secret  { 'ppp_user2':
          ensure => 'absent',
        }
        
        # ip address spec
        mikrotik_ip_address { '192.168.201.1/24':
          ensure => absent,
        }
        
        mikrotik_ip_pool { 'SWIMMING':
          ensure => absent,
        }
  
        mikrotik_ip_pool { 'POOL2':
          ensure => absent,
        }
      
        mikrotik_dhcp_server_network { 'DHCPD_NET1':
          ensure => absent,
        }
      
        mikrotik_dhcp_server { 'DHCPD1':
          ensure => absent,
        }
  
        mikrotik_interface_vlan { 'VLAN_DHCP':
          ensure => absent,
        }
          
        # route spec
        mikrotik_ip_route { 'test_route1':
          ensure => absent,
        }
    
        mikrotik_ip_route { 'test_route2':
          ensure => absent,
        }
        
        mikrotik_ip_route_rule { 'test_rule1':
          ensure => absent,
        }
        
        mikrotik_ip_route_rule { 'test_rule2':
          ensure => absent,
        } 
          
        mikrotik_ip_route_vrf { 'VRF_1001':
          ensure => absent,
        }
  
        mikrotik_interface_vlan { 'VRF_VLAN1001':
          ensure => absent,          
        }
        
        mikrotik_routing_filter { 'test_filter1':
          ensure => absent,          
        }
        
        mikrotik_routing_filter { 'test_filter2':
          ensure => absent,          
        }
        
        mikrotik_routing_filter { 'test_filter3':
          ensure => absent,          
        }        
  
        # mpls spec
        mikrotik_mpls_ldp { 'ldp':
          ensure            => disabled,
          lsr_id            => '0.0.0.0',
          transport_address => '0.0.0.0',
          loop_detect       =>  false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
  
      # Agents: Puppet Device
      @result = run_puppet_device_on(agents)
      # Changes are not required here
      
      @result = run_puppet_device_on(agents)
      expect(@result.exit_code).to eq(0)    
    end
  end
end
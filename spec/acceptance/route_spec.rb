require 'spec_helper_acceptance'

describe '/ip/route' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_route { ['test_route1', 'test_route2']:
          ensure => absent,
        }
    
        mikrotik_ip_route_rule { ['test_rule1', 'test_rule2']:
          ensure => absent,
        }
                  
        mikrotik_ip_route_vrf { 'VRF_1001':
          ensure => absent,
        }
  
        mikrotik_interface_vlan { 'VRF_VLAN1001':
          ensure => absent,          
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 4
  end  
  
  context "create ip routes" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route { 'test_route1':
          dst_address  => '172.22.0.0/24',
          gateway      => '172.16.0.1',
          distance     => 50,
          routing_mark => 'TEST_TABLE',
        }  
        
        mikrotik_ip_route { 'test_route2':
          ensure      => disabled,
          dst_address => '172.22.1.0/24',
          type        => 'blackhole',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update ip route" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route { 'test_route1':
          dst_address   => '172.22.0.0/24',
          distance      => 60,
          check_gateway => ping,
        }     
          
        mikrotik_ip_route { 'test_route2':
          ensure      => enabled,
          dst_address => '172.22.1.0/24',
        }     
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create ip route rule" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route_rule { 'test_rule1':
          ensure      => disabled,
          src_address => '172.24.0.0/24',
          dst_address => '172.24.1.0/24',     
          action      => unreachable,
        }   
        
        mikrotik_ip_route_rule { 'test_rule2':
          ensure       => enabled,
          routing_mark => 'ROUTE_TABLE1',
          interface    => 'ether1',     
          action       => lookup,
          table        => 'ROUTE_TABLE1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "enable ip route rule" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route_rule { 'test_rule1':
          ensure => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create ip route vrf" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VRF_VLAN1001':
          vlan_id   => 1001,
          interface => 'ether1',
        }
      
        mikrotik_ip_route_vrf { 'VRF_1001':
          ensure     => enabled,
          interfaces => 'VRF_VLAN1001'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable ip route vrf" do
    it 'should update master' do
      site_pp = <<-EOS      
      mikrotik_ip_route_vrf { 'VRF_1001':
          ensure => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/routing/filter' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_routing_filter { ['test_filter1', 'test_filter2', 'test_filter3']:
          ensure => absent,          
        }
                
        mikrotik_routing_filter { ['filter_chain2', 'filter_chain3', 'filter_chain4']:
          ensure => absent,          
        }
      
        mikrotik_routing_filter { ['filter_a', 'filter_b', 'filter_c', 'filter_d', 'filter_e', 'filter_f', 'filter_g', 'filter_h', 'filter_i']:
          ensure => absent,          
        }
        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 4
  end  
  
  
  context "create new filter" do
    it 'should update master' do
      site_pp = <<-EOS   
        mikrotik_routing_filter { 'test_filter1':
          chain         => 'OSPF_TEST1',
          prefix        => '172.22.0.0/16',
          prefix_length => '25-32',
          protocols     => ['ospf'],
          ospf_type     => 'external-type-2',
          action        => 'discard',
        }
        
        mikrotik_routing_filter { 'test_filter2':
          ensure       => enabled,
          chain        => 'BGP_IN_TEST2',        
          action       => 'jump',  
          jump_target  => 'test_filter3',
          set_distance => 150,
        }     
        
        mikrotik_routing_filter { 'test_filter3':
          ensure                 => disabled,
          chain                  => 'BGP_OUT_TEST3',
          protocols              => ['bgp'], 
          bgp_communities        => ['62123:20000', '62123:10000'],
          action                 => 'accept',
          set_bgp_weight         => 100,
          set_bgp_local_pref     => 150,
          set_bgp_prepend        => 3,   
          set_bgp_med            => 50,                   
          append_bgp_communities => ['62124:30000'],
        }              
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "enable/disable filter" do
    it 'should update master' do
      site_pp = <<-EOS   
        mikrotik_routing_filter { 'test_filter2':
          ensure => disabled,
          chain  => 'BGP_IN_TEST2',        
        }             
         
        mikrotik_routing_filter { 'test_filter3':
          ensure => enabled,
          chain  => 'BGP_OUT_TEST3',
        }              
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "sort on insert" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { 'filter_chain2':
          chain         => 'chain2',
          prefix        => '1.2.3.100',
          action        => 'accept',
        }
              
        mikrotik_routing_filter { 'filter_a':
          chain         => 'testing_sort',
          chain_order   => 1,
          prefix        => '1.2.3.2',
          action        => 'accept',
        }
  
        mikrotik_routing_filter { 'filter_d':
          chain         => 'testing_sort',
          chain_order   => 3,
          prefix        => '1.2.3.4',
          action        => 'accept',
        }
  
        mikrotik_routing_filter { 'filter_chain3':
          chain         => 'chain3',
          prefix        => '1.2.3.110',
          action        => 'accept',
        }

        mikrotik_routing_filter { 'filter_b':
          chain         => 'testing_sort',
          chain_order   => 2,
          prefix        => '1.2.3.1',
          action        => 'accept',
        }
        
        mikrotik_routing_filter { 'filter_f':
          chain         => 'testing_sort',
          chain_order   => 5,
          prefix        => '1.2.3.7',
          action        => 'accept',
        }
  
        mikrotik_routing_filter { 'filter_e':
          chain         => 'testing_sort',
          chain_order   => 4,
          prefix        => '1.2.3.5',
          action        => 'accept',
        }
  
        mikrotik_routing_filter { 'filter_chain4':
          chain         => 'chain4',
          prefix        => '1.2.3.120',
          action        => 'accept',
        }  
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "insert more" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { 'filter_c':
          chain         => 'testing_sort',
          chain_order   => 3,
          prefix        => '1.2.3.3',
          action        => 'accept',
        }
  
        mikrotik_routing_filter { 'filter_g':
          chain         => 'testing_sort',
          chain_order   => 7,
          prefix        => '1.2.3.6',
          action        => 'accept',
        }  
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "move filters" do
    it 'should update master' do
      site_pp = <<-EOS
        # side-by-side swap (starting FORWARD)
        mikrotik_routing_filter { 'filter_a':
          chain         => 'testing_sort',
          chain_order   => 2,
        }

        # Should not make a change anymore
        mikrotik_routing_filter { 'filter_b':
          chain         => 'testing_sort',
          chain_order   => 1,
        }  
        
        # BACKWARD change
        mikrotik_routing_filter { 'filter_g':
          chain         => 'testing_sort',
          chain_order   => 6,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "move filter to start of chain" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { 'filter_f':
          chain         => 'testing_sort',
          chain_order   => 1,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "move filter to end of chain" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { 'filter_b':
          chain         => 'testing_sort',
          chain_order   => 7,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "complex move" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { 'filter_chain2':
          ensure => absent,
        }
        
        mikrotik_routing_filter { 'filter_chain3':
          ensure => absent,
        }
        
        mikrotik_routing_filter { 'filter_chain4':
          ensure => absent,
        }      
      
        mikrotik_routing_filter { 'filter_f':
          chain         => 'testing_sort',
          chain_order   => 2,
        }  
        
        mikrotik_routing_filter { 'filter_g':
          chain         => 'testing_sort',
          chain_order   => 3,
        }  
        
        mikrotik_routing_filter { 'filter_e':
          chain         => 'testing_sort',
          chain_order   => 4,
        }  
        
        mikrotik_routing_filter { 'filter_d':
          chain         => 'testing_sort',
          chain_order   => 5,
        }  
      
        mikrotik_routing_filter { 'filter_c':
          chain         => 'testing_sort',
          chain_order   => 6,
        }
  
        mikrotik_routing_filter { 'filter_a':
          chain         => 'testing_sort',
          chain_order   => 7,
        }  
        
        mikrotik_routing_filter { 'filter_b':
          chain         => 'testing_sort',
          chain_order   => 8,
        }

        mikrotik_routing_filter { 'filter_h':
          chain         => 'testing_sort',
          chain_order   => 9,
          prefix        => '1.2.3.0/30',
          action        => 'accept',
        }  
        
        mikrotik_routing_filter { 'filter_i':
          chain         => 'testing_sort',
          chain_order   => 1,
          prefix        => '1.2.3.8',
          action        => 'accept',
        }  
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "cleanup" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_routing_filter { ['filter_chain2', 'filter_chain3', 'filter_chain4']:
          ensure => absent,          
        }
      
        mikrotik_routing_filter { ['filter_a', 'filter_b', 'filter_c', 'filter_d', 'filter_e', 'filter_f', 'filter_g', 'filter_h', 'filter_i']:
          ensure => absent,          
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

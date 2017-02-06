require 'spec_helper_acceptance'

describe '/ip/route' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
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
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create ip route rule" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route_rule { 'test_rule1':
          src_address => '172.24.0.0/24',
          dst_address => '172.24.1.0/24',     
          action      => unreachable,
        }   
        
        mikrotik_ip_route_rule { 'test_rule2':
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

  context "create ip route vrf" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VRF_VLAN1001':
          vlan_id   => 1001,
          interface => 'ether1',
        }
      
        mikrotik_ip_route_vrf { 'VRF_1001':
          interfaces => 'VRF_VLAN1001'
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
          chain        => 'BGP_IN_TEST2',        
          action       => 'jump',  
          jump_target  => 'test_filter3',
          set_distance => 150,
        }     
        
        mikrotik_routing_filter { 'test_filter3':
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
end

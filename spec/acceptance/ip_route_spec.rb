require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
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

  context "enable ip route vrf" do    # REQUIRED BY IP ROUTE !
    it 'should update master' do
      site_pp = <<-EOS      
      mikrotik_ip_route_vrf { 'VRF_1001':
          ensure => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create ip routes" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_route { 'test_route1':
          dst_address  => '172.22.0.0/24',
          gateway      => '172.16.0.1',
          distance     => 50,
          routing_mark => 'VRF_1001',
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
          routing_mark => 'VRF_1001',
          interface    => 'ether1',     
          action       => lookup,
          table        => 'VRF_1001',
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
end

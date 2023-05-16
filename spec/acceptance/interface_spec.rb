require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe '/interface' do  
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vrrp { 'br0_vip':
          ensure => absent,        
        }

        mikrotik_interface_bond { 'ip_tnl_bond':
          ensure => absent,
        }
  
        mikrotik_interface_eoip { ['ip_tnl_01', 'ip_tnl_02']:
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
        
        mikrotik_interface_bgp_vpls { 'Virtual1':
          ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 9
  end  
  
  context "create eoip" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_eoip { 'ip_tnl_01':
          local_address  => '10.150.1.1',
          remote_address => '10.150.1.2',
          tunnel_id      => '1501',
        }
          
        mikrotik_interface_eoip { 'ip_tnl_02':
          ensure         => disabled,
          local_address  => '10.150.2.1',
          remote_address => '10.150.2.2',
          tunnel_id      => '1502',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create vrrp" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vrrp { 'br0_vip':   
          ensure          => enabled,       
          interface       => 'br0',
          vrid            => 123,
          priority        => 50,
          preemption_mode => false,
          # authentication  => 'simple',
          # password        => 'secret',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create vlan" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VLAN_4001':  
          ensure    => enabled,    
          vlan_id   => '4001',
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create bond" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bond { 'ip_tnl_bond':      
          slaves               => ['ip_tnl_01', 'ip_tnl_02'],
          mode                 => '802.3ad',
          link_monitoring      => 'mii',
          transmit_hash_policy => 'layer-2',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create vpls bgp interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bgp_vpls { 'Virtual1':
          route_distinguisher  => '1234:54321',            
          import_route_targets => ['1234:54321', '1234:54322'],
          export_route_targets => '1234:54321',                  
          site_id              => 1,
          bridge               => 'br0',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "rename ethernet" do      
    it 'should update master' do
      site_pp = <<-EOS
      mikrotik_interface_ethernet { 'ether1':      
          alias => 'ether1-test',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  # Don't mess with future tests...
  context "reset ethernet name" do      
    it 'should update master' do
      site_pp = <<-EOS
      mikrotik_interface_ethernet { 'ether1':      
          alias => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create interface list" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_list { 'interface_list_1':
          members => ['VLAN_4001', 'ip_tnl_01']
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update interface list" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_list { 'interface_list_1':
          members => ['VLAN_4001', 'ip_tnl_bond']
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update vpls bgp interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bgp_vpls { 'Virtual1':  
          import_route_targets => ['1234:54322', '1234:54323'],
          export_route_targets => '1234:54322',                  
          bridge_cost          => 100,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable some interfaces" do      
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_interface_eoip { 'ip_tnl_01':
          ensure => disabled
        }
        
        mikrotik_interface_vrrp { 'br0_vip':  
          ensure => disabled
        }
        
        mikrotik_interface_vlan { 'VLAN_4001':      
          ensure => disabled
        }
        
        mikrotik_interface_bond { 'ip_tnl_bond':   
          ensure => disabled
        }
          
        mikrotik_interface_bgp_vpls { 'Virtual1':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
  
  context "enable some interfaces" do      
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_interface_eoip { 'ip_tnl_01':
          ensure => enabled
        }
        
        mikrotik_interface_vrrp { 'br0_vip':  
          ensure => enabled
        }
        
        mikrotik_interface_vlan { 'VLAN_4001':      
          ensure => enabled
        }
        
        mikrotik_interface_bond { 'ip_tnl_bond':   
          ensure => enabled
        }
          
        mikrotik_interface_bgp_vpls { 'Virtual1':
          ensure => enabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
end

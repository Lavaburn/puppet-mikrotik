require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe '/interface/bridge' do  
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  describe '/interface bridge settings' do  
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_interface_bridge_settings { 'bridge':
            allow_fast_path           => true,
            use_ip_firewall           => false,
            use_ip_firewall_for_pppoe => false,
            use_ip_firewall_for_vlan  => false,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
   
      it_behaves_like 'an idempotent device run after failures', 1
    end  
  
    context "enable firewall for bridged PPPoE" do
      it 'should update master' do
        site_pp = <<-EOS                
          mikrotik_interface_bridge_settings { 'bridge':
            use_ip_firewall_for_pppoe => true,
          }    
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end # EXPECT FAILURE !!
  
    context "enable firewall for bridged VLAN" do
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_interface_bridge_settings { 'bridge':
            use_ip_firewall           => true,
            use_ip_firewall_for_pppoe => true,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "disable fastpath" do
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_interface_bridge_settings { 'bridge':
            allow_fast_path => false,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "with wrong title" do
      it 'should update master' do
        site_pp = <<-EOS               
          mikrotik_interface_bridge_settings { 'MyBridge2':
            allow_fast_path => true,
          }        
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'a faulty device run'
    end
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_msti_port { '4011_2':  
          ensure => absent,
        }
      
        mikrotik_interface_bridge_msti { ['mst_402', 'mst_403']:
          ensure => absent,
        }

        mikrotik_interface_bridge_vlan { ['vlan_402', 'vlan_403']:   
          ensure => absent,
        }      
      
        mikrotik_interface_bridge_port { ['VLAN_4011', 'VLAN_4012']:
          ensure => absent,
        }

        mikrotik_interface_vlan { ['VLAN_4011', 'VLAN_4012']:
          ensure => absent,
        }
        
        mikrotik_interface_bridge { 'MSTP_TEST':
          ensure => absent,
        }

        # LEGACY
        mikrotik_interface_bridge_port { 'VLAN_4001':
          ensure => absent,
        }
        
        mikrotik_interface_bridge { ['br0', 'br1', 'br2']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 2
  end  
  
  context "create new bridge" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VLAN_4011':  
          ensure    => enabled,    
          vlan_id   => '4011',
          interface => 'ether1',
        }
        
        mikrotik_interface_vlan { 'VLAN_4012':  
          ensure    => enabled,    
          vlan_id   => '4012',
          interface => 'ether1',
        }

        mikrotik_interface_bridge { 'MSTP_TEST':
          vlan_filtering => true,
          pvid           => "21",
        }

        # LEGACY
        mikrotik_interface_bridge { 'br0':
          
        }
        
        mikrotik_interface_bridge { 'br1':
          mtu => 1300,
          admin_mac => '02:02:02:12:34:56',
        }
        
        mikrotik_interface_bridge { 'br2':
          ensure => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  

  context "update bridge" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge { 'MSTP_TEST':
          protocol_mode   => 'mstp',
          priority        => '0x6000',
          region_name     => 'TEST',
          region_revision => '1',
        }

        # LEGACY
        mikrotik_interface_bridge { 'br0':
          mtu => 1000,
        }
        
        mikrotik_interface_bridge { 'br1':
          mtu => 1200,
        }
        
        mikrotik_interface_bridge { 'br2':
          ensure => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "attach to bridge" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_port { 'VLAN_4011':      
          bridge  => 'MSTP_TEST',
          horizon => '40',
          pvid    => '4011',
        }
        
        mikrotik_interface_bridge_port { 'VLAN_4012':      
          bridge  => 'MSTP_TEST',
          horizon => '40',
          pvid    => '4012',
        }
        
        # LEGACY
        mikrotik_interface_bridge_port { 'VLAN_4001':      
          bridge => 'br0',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update bridge ports" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_port { 'VLAN_4011':      
          bridge            => 'MSTP_TEST',
          ingress_filtering => true,
        }
        
        mikrotik_interface_bridge_port { 'VLAN_4012':
          bridge             => 'MSTP_TEST',
          priority           => '0x60',
          path_cost          => '20',
          internal_path_cost => '15',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create bridge vlans" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_vlan { 'vlan_402':   
          bridge   => 'MSTP_TEST',   
          tagged   => [ 'VLAN_4011', 'VLAN_4012' ],
          vlan_ids => [ '4021', '4022' ],
        }
  
        mikrotik_interface_bridge_vlan { 'vlan_403':   
          bridge   => 'MSTP_TEST',   
          vlan_ids => [ '4031', '4032', '4033' ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update bridge vlans" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_vlan { 'vlan_402':   
          bridge   => 'MSTP_TEST',   
          vlan_ids => [ '4021', '4022', '4023' ],
        }
        
        mikrotik_interface_bridge_vlan { 'vlan_403':   
          bridge   => 'MSTP_TEST',   
          vlan_ids => [ '4031', '4032' ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create MST instances" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_msti { 'mst_402':   
          bridge       => 'MSTP_TEST',
          identifier   => '2',
          vlan_mapping => [ '4021-4029' ],
        }
        
        mikrotik_interface_bridge_msti { 'mst_403':   
          bridge       => 'MSTP_TEST',
          identifier   => '3',
          vlan_mapping => [ '4031-4039' ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update MST instances" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_msti { 'mst_402':   
          bridge       => 'MSTP_TEST',
          identifier   => '2',
          priority     => '0x6000',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "create port MST override" do 
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_msti_port { '4011_2':   
          interface    => 'VLAN_4011',
          identifier   => '2',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update port MST override" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge_msti_port { '4011_2':   
          interface          => 'VLAN_4011',
          identifier         => '2',
          priority           => '0x40',
          internal_path_cost => '20',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable bridge" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge { 'br0':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  

  context "enable bridge" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_bridge { 'br0':
          ensure => enabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end

require 'spec_helper_acceptance'

describe 'v7: /routing/bgp' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_v7_bgp_vpn { ['123:1', '456:1']:
          ensure   => absent,
        }
        
        mikrotik_v7_bgp_template { ['tpl1', 'tpl2', 'tpl3']:
          ensure   => absent,
        }

        mikrotik_v7_bgp_connection { ['peer1', 'peer2', 'peer3']:
          ensure   => absent,
        }
        
        # Ensure VRF exists
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
  
    it_behaves_like 'an idempotent device run after failures', 5
  end  

  describe '/routing/bgp/vpn' do    
    context "create BGP instance VRF" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_vpn { '123:1':
            ensure               => 'disabled',
            import_route_targets => [ '123:2' ],
            export_route_targets => [ '123:3' ], 
            redistribute         => ['connected', 'static'],
          }       
             
          mikrotik_v7_bgp_vpn { '456:1':
            ensure               => 'enabled',
            vrf                 => 'VRF_1001',
            import_route_targets => [ '456:2' ], 
          }          
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "update BGP instance VRF" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_vpn { '123:1':
            redistribute  => ['connected'],
            import_filter => 'FILTER1',
          }        
           
          mikrotik_v7_bgp_vpn { '456:1':
            import_route_targets => [ '456:3' ], 
          }          
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "enable/disable BGP instance VRF" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_vpn { '123:1':
            ensure   => 'enabled',
          }         
         
          mikrotik_v7_bgp_vpn { '456:1':
            ensure   => 'disabled',
          }         
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end  
  end
  
  describe '/routing/bgp/template' do
    context "create templates" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_template { 'tpl1':
            as                => '123',
            address_families  => ['ip'],
            multihop          => true,
            redistribute      => ['connected',  'static', 'bgp'],
            default_originate => 'if-installed',
          }
          mikrotik_v7_bgp_template { 'tpl2':
            as        => '456',
            templates => ['tpl1'],
            use_bfd   => true,
            disable_client_to_client_relection => true,
          }
          mikrotik_v7_bgp_template { 'tpl3':
            as               => '780',
            address_families => ['l2vpn', 'vpnv4'],
            nexthop_choice   => 'force-self',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
      
    context "update templates" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_template { 'tpl1':
            address_families => ['ip', 'ipv6'],        
            redistribute     => ['connected',  'static', 'vpn'],
          }
          mikrotik_v7_bgp_template { 'tpl2':
            disable_client_to_client_relection => false,            
          }
          mikrotik_v7_bgp_template { 'tpl3':
            as                => '789',            
            add_path_out      => 'all',
            remove_private_as => true,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
      
    context "disable template" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_template { 'tpl2':
            ensure => disabled,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end   
  end
  
  describe '/routing/bgp/connection' do    
    context "create connections" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_connection { 'peer1':
            templates        => ['tpl1'],
            address_families => ['ip'],              
            remote_address => '1.2.3.4',
            remote_as      => '321',
            local_role     => 'ebgp',
            tcp_md5_key    => 'password',
            multihop       => true,
          }
          
          mikrotik_v7_bgp_connection { 'peer2':
            templates      => ['tpl3'],              
            remote_address => '1.2.3.5',            
          }
          
          mikrotik_v7_bgp_connection { 'peer3':              
            remote_address => '1.2.3.6',
            remote_as      => '654',
            local_role     => 'ebgp-rs',  
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
      
    context "update connections" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_connection { 'peer1':
            templates      => ['tpl1'],  
            tcp_md5_key    => 'password2',
            multihop       => false,  
            local_address  => '192.168.201.1',
          }
          
          mikrotik_v7_bgp_connection { 'peer2':
            templates      => ['tpl1'],   
            local_role     => 'ibgp-rr',
          }
          
          mikrotik_v7_bgp_connection { 'peer3':             
            remote_address => '1.2.3.7',
            local_role     => 'ebgp',  
            as             => '123',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "disable connection" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_bgp_connection { 'peer3':
            ensure => disabled,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end  
  end
end

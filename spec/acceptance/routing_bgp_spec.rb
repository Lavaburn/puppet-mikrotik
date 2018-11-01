require 'spec_helper_acceptance'

describe '/routing/bgp' do
  #before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_bgp_instance { 'PUPPET':
          ensure => absent,
        }
        
        mikrotik_bgp_peer { 'peer1':
          ensure => absent,
        }
  
        mikrotik_bgp_network { ['1.1.1.0/24', '1.1.2.0/24', '1.1.3.0/24']: 
          ensure => absent,
        }
          
        mikrotik_bgp_aggregate { ['1.1.0.0/16', '1.2.0.0/16', '1.3.0.0/16']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 4
  end  

  context "instance creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_instance { 'PUPPET':
          as                          => '64500',
          router_id                   => '1.2.3.4',
          redistribute_connected      => true,
          redistribute_static         => true,
          out_filter                  => 'PUPPET_OUT',
          client_to_client_reflection => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "instance update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_instance { 'PUPPET':
          redistribute_connected      => false,
          redistribute_static         => false,
          out_filter                  => 'PUPPET_OUT1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "create peer" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'peer1':
          instance           => 'PUPPET',
          peer_address       => '1.2.3.6',
          peer_as            => '64500',
          source             => 'ether1',       
          out_filter         => 'PUPPET_PEER_OUT',
          in_filter          => 'PUPPET_PEER_IN',
          route_reflect      =>  true,
          default_originate  => 'always',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "update peer 1" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'peer1':
          source             => '1.2.3.4',   
          out_filter         => 'PUPPET_PEER_OUT2',
          in_filter          => 'PUPPET_PEER_IN2',
          route_reflect      =>  false,
          default_originate  => 'if-installed',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update peer 2" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'peer1':
          nexthop_choice  => 'force-self',
          multihop        => true,
          route_reflect   => false,
          passive         => true,
          source          => 'ether1',            
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update peer 3" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'peer1':
          nexthop_choice    => 'propagate',
          multihop          => false,
          route_reflect     => true,
          remove_private_as => true,
          as_override       => true,
          use_bfd           => true,
          address_families  => ['ip', 'l2vpn'],
          comment           => 'VPLS peer',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable peer" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'peer1':
          ensure => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create BGP aggregate" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_aggregate { '1.1.0.0/16': 
          instance         => 'PUPPET',
          summary_only     => true,
          attribute_filter => 'ATTRIBS1'
        }
          
        mikrotik_bgp_aggregate { '1.2.0.0/16': 
          ensure             => present,
          instance           => 'PUPPET',
          inherit_attributes => false,
          suppress_filter    => 'SUPRESS2',
        }
          
        mikrotik_bgp_aggregate { '1.3.0.0/16': 
          ensure           => disabled,
          instance         => 'PUPPET',
          include_igp      => true,
          advertise_filter => 'ADV3',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update BGP aggregate" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_aggregate { '1.1.0.0/16': 
          instance         => 'PUPPET',
          summary_only     => false,
          suppress_filter  => 'SUPRESS1',
        }
          
        mikrotik_bgp_aggregate { '1.2.0.0/16': 
          ensure             => disabled,
          instance           => 'PUPPET',
          inherit_attributes => true,
          suppress_filter    => 'SUPRESSNEW',
        }
          
        mikrotik_bgp_aggregate { '1.3.0.0/16': 
          ensure           => enabled,
          instance         => 'PUPPET',
          include_igp      => false,
          advertise_filter => 'ADVNEW',
          suppress_filter  => 'SUPRESS3',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "remove BGP aggregate" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_aggregate { '1.1.0.0/16': 
          ensure => absent,
        }
          
        mikrotik_bgp_aggregate { '1.2.0.0/16': 
          ensure => absent,
        }
          
        mikrotik_bgp_aggregate { '1.3.0.0/16': 
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "create BGP network" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_network { '1.1.1.0/24': 
          
        }
        
        mikrotik_bgp_network { '1.1.2.0/24': 
          ensure      => present,
          synchronize => false,
        }
        
        mikrotik_bgp_network { '1.1.3.0/24': 
          ensure => enabled,  
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update BGP network" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_network { '1.1.2.0/24': 
          synchronize => true,
        } 
        
        mikrotik_bgp_network { '1.1.3.0/24': 
          ensure => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "remove BGP network" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_network { '1.1.1.0/24': 
          ensure => absent,
        }
        
        mikrotik_bgp_network { '1.1.2.0/24': 
          ensure => absent,
        }
        
        mikrotik_bgp_network { '1.1.3.0/24': 
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

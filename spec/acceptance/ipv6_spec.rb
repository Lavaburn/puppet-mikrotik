require 'spec_helper_acceptance'

describe '/system/package' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_package { 'ipv6':
          ensure => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "disable package" do      
    it 'should update master' do
      site_pp = <<-EOS           
        mikrotik_package { 'ipv6':
          ensure => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run'
  end

  context "enable package and reboot" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_package { 'ipv6':
          ensure       => enabled,
          force_reboot => true          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run'
  end
end

describe '/ipv6/address' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_address { ['2001:db8:1::/64', '2001:db8:2::/64']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "create new address" do
    it 'should update master' do
      site_pp = <<-EOS
        # TODO: fix and test: "eui64 => true" is never idempotent!                                                              # TODO !
      
        mikrotik_ipv6_address { '2001:db8:1::1/64':
          interface => 'ether1',
          advertise => false,
        }
        
        mikrotik_ipv6_address { '2001:db8:2::1/64':
          ensure    => disabled,          
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "enable/disable address" do
    it 'should update master' do
      site_pp = <<-EOS       
      mikrotik_ipv6_address { '2001:db8:1::1/64':
          ensure    => disabled,          
          interface => 'ether1',
        }
        
        mikrotik_ipv6_address { '2001:db8:2::1/64':
          ensure    => enabled,          
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/ipv6/route' do
  before { skip("Skipping this test for now") }

  include_context 'testnodes defined'

  context "reset configuration" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_route { ['test_route61', 'test_route62']:
          ensure => absent,
        }
      EOS

      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "create ip routes" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ipv6_route { 'test_route61':
          dst_address  => '2000::/4',
          gateway      => 'ether1',
          distance     => 50,
        }  

        mikrotik_ipv6_route { 'test_route62':
          ensure      => disabled,
          dst_address => '1000::/4',
          type        => 'unreachable',
        }
      EOS

      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run'
  end

  context "update ip route" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ipv6_route { 'test_route61':
          dst_address   => '2000::/3',
          distance      => 60,
          check_gateway => ping,
        }     
          
        mikrotik_ipv6_route { 'test_route62':
          ensure      => enabled,
          dst_address => 'a000::/4',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
end

describe '/ipv6/pool' do  
  before { skip("Skipping this test for now") }
    
  include_context 'testnodes defined'
  
  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS              
        mikrotik_ipv6_pool { ['SWIMMING']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "create new ip pool" do
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_ipv6_pool { 'SWIMMING':
          prefix        => '2001:db8:1000::/48',
          prefix_length => '56',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/ipv6/dhcp' do  
  before { skip("Skipping this test for now") }
    
  include_context 'testnodes defined'
  
  context "reset configuration" do           
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_dhcpv6_server { 'DHCPD1':
          ensure => absent,
        }
  
        mikrotik_dhcpv6_client { 'ether1':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 2
  end  
  
  # Server
  context "create dhcp server" do            
    it 'should update master' do
      site_pp = <<-EOS
        # Default = disabled (!)
        mikrotik_dhcpv6_server { 'DHCPD1':
          interface     => 'ether1',
          lease_time    => '6h',
          address_pool  => 'SWIMMING',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable dhcp server" do  
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcpv6_server { 'DHCPD1':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "enable dhcp server" do       
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcpv6_server { 'DHCPD1':
          ensure     => enabled,
          lease_time => '2h'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  # Client
  context "create dhcp client" do            
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcpv6_client { 'ether1':
          request_address => true,
          use_peer_dns    => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable dhcp client" do  
    it 'should update master' do
      site_pp = <<-EOS
      mikrotik_dhcpv6_client { 'ether1':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update dhcp client" do       
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcpv6_client { 'ether1':
          request_prefix => true,
          pool_name      => 'TESTPOOL'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/ipv6/nd' do  
  before { skip("Skipping this test for now") }
    
  include_context 'testnodes defined'
  
  context "reset configuration" do           
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_nd_interface { 'ether1':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "create nd interface" do            
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_nd_interface { 'ether1':    
          hop_limit     => 10,
          advertise_dns => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable nd interface" do  
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_nd_interface { 'ether1':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update nd interface" do       
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ipv6_nd_interface { 'ether1': 
          ra_delay               => '5s',
          reachable_time         => '30s', 
          managed_address_config => true,
          other_config           => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

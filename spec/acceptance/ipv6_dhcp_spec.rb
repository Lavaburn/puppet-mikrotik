require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe 'IPv6 DHCP' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  describe 'v6 - /system/package' do
    before { skip("Optional - Required on new v6 systems") }
    # Not supported on v7
  
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

  describe '/ipv6/pool' do      
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
end

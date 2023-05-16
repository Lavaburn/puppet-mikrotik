require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe 'IPv6 Generic' do
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

  describe '/ipv6 settings' do  
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_ipv6_settings { 'ipv6':
            accept_redirects             => true,
            accept_router_advertisements => 'yes-if-forwarding-disabled',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
   
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "accept_redirects=false" do
      it 'should update master' do
        site_pp = <<-EOS                
          mikrotik_ipv6_settings { 'ipv6':
            accept_redirects => false,
          }    
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "accept_router_advertisements=no" do
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_ipv6_settings { 'ipv6':
            accept_router_advertisements => 'no',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "with wrong title" do
      it 'should update master' do
        site_pp = <<-EOS               
          mikrotik_ipv6_settings { 'MyIP6':
            accept_router_advertisements => 'no',
          }        
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'a faulty device run'
    end
  end
  
  describe '/ipv6/address' do  
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
  
  describe '/ipv6/nd' do      
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
end

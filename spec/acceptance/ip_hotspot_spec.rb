require 'spec_helper_acceptance'

describe '/ip/hotspot' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_hotspot_profile { 'hs_profile_a':
          ensure => 'absent',
        }
        mikrotik_ip_hotspot { 'hotspot1':
          ensure => 'absent',
        }

        mikrotik_interface_vlan { 'VLAN_4001':  
          ensure    => present,    
          vlan_id   => '4001',
          interface => 'ether1',
        }
        
        mikrotik_ip_pool { 'POOL2':
          ensure => present,    
          ranges => '172.23.9.1-172.23.9.100'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 4
  end  
  
  context "create hotspot" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_hotspot_profile { 'hs_profile_a':
          hotspot_address       => '192.168.88.1',
          login_by              => [ 'http-chap', 'cookie' ],
          use_radius            => true,
          radius_interim_update => '5m',
        }
        
        mikrotik_ip_hotspot { 'hotspot1':
          ensure            => 'enabled',
          interface         => 'VLAN_4001',
          address_pool      => 'POOL2',
          profile           => 'default',
          keepalive_timeout => '1m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update hotspot" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_hotspot_profile { 'hs_profile_a':
          split_user_domain     => true,
          radius_default_domain => 'CLIENT',
        }
        
        mikrotik_ip_hotspot { 'hotspot1':
          ensure       => 'enabled',
          profile      => 'hs_profile_a',
          idle_timeout => '2m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable hotspot" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_hotspot { 'hotspot1':
          ensure => 'disabled',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

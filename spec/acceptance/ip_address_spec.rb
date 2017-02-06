require 'spec_helper_acceptance'

describe '/ip/address' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create new address" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_address { '192.168.201.1/24':
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/ip/pool' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create new ip pool" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_pool { 'POOL2':
          ranges => '172.23.9.1-172.23.9.100'
        }
        
        mikrotik_ip_pool { 'SWIMMING':
          ranges => [
            '172.23.0.1-172.23.3.255',
            '172.23.5.1-172.23.8.255',
          ],
          next_pool => 'POOL2',
        }    
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

describe '/ip/dhcp' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create dhcp server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VLAN_DHCP':
          vlan_id   => '4010',
          interface => 'ether1',
        }
        
        # Default = disabled (!)
        mikrotik_dhcp_server { 'DHCPD1':
          interface     => 'VLAN_DHCP',
          lease_time    => '6h',
          address_pool  => 'SWIMMING',
          authoritative => 'after-2sec-delay',
          use_radius    => true,
        }
        
        mikrotik_dhcp_server_network { '172.21.100.0/24':    
          gateways    => ['172.21.100.1', '172.21.100.2'],
          dns_servers => ['105.235.209.31', '105.235.209.32'],
          domain      => 'rcswimax.com',
        }   
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "enable dhcp server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcp_server { 'DHCPD1':
          ensure => enabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable dhcp server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dhcp_server { 'DHCPD1':
          ensure => disabled
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

end

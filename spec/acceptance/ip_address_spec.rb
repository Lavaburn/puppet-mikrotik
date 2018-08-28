require 'spec_helper_acceptance'

describe '/ip/address' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_address { ['192.168.201.1/24', '192.168.202.1/24']:
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
        mikrotik_ip_address { '192.168.201.1/24':
          interface => 'ether1',
        }
        
        mikrotik_ip_address { '192.168.202.1/24':
          ensure    => disabled,
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "enable address" do
    it 'should update master' do
      site_pp = <<-EOS           
        mikrotik_ip_address { '192.168.202.1/24':
          ensure    => enabled,
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
  
  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS              
        mikrotik_ip_pool { ['SWIMMING', 'POOL2']:
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
  
  context "reset configuration" do           
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_dhcp_server { ['DHCPD1', 'DHCPD2']:
          ensure => absent,
        }
        
        mikrotik_dhcp_server_network { 'DHCPD_NET1':
          ensure => absent,
        }
                      
        mikrotik_interface_vlan { ['VLAN_DHCP1', 'VLAN_DHCP2']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 3
  end  
  
  context "create dhcp server" do            
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_vlan { 'VLAN_DHCP1':
          vlan_id   => '4010',
          interface => 'ether1',
        }
          
        mikrotik_interface_vlan { 'VLAN_DHCP2':
          vlan_id   => '4020',
          interface => 'ether1',
        }
        
        # Default = disabled (!)
        mikrotik_dhcp_server { 'DHCPD1':
          interface     => 'VLAN_DHCP1',
          lease_time    => '6h',
          address_pool  => 'SWIMMING',
          authoritative => 'after-2sec-delay',
          use_radius    => true,
        }
          
        mikrotik_dhcp_server { 'DHCPD2':
          ensure        => enabled,
          interface     => 'VLAN_DHCP2',
          lease_time    => '1h',
          address_pool  => 'SWIMMING',
          authoritative => 'after-10sec-delay',
          use_radius    => false,
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

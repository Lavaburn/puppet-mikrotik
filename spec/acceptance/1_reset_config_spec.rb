require 'spec_helper_acceptance'

describe 'reset configuration' do
  #before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "first run" do  
    before(:all) do
      @pp = <<-EOS
        contain ::mikrotik
      EOS
    end
    
    it 'should run manifest idempotently' do
      @result = apply_manifests(agents, @pp)
      
      @result = apply_manifests(agents, @pp)
      expect(@result.exit_code).to eq(0)
    end
  
    it 'should reset configuration idempotently' do    
      site_pp = <<-EOS
        mikrotik_dns { 'dns':
          servers               => ['8.8.8.8','8.8.4.4'],
          allow_remote_requests => true,
        }
        
        mikrotik_firewall_rule { 'Puppet Test 1':
          ensure   => 'absent',
        }
        mikrotik_firewall_rule { 'Puppet Test 2':
          ensure   => 'absent',
        }
        mikrotik_firewall_rule { 'Puppet Test 3':
          ensure   => 'absent',
        }
        mikrotik_address_list { 'MT_TEST_LIST':
          ensure => 'absent',
        }        
        mikrotik_ip_service { 'telnet':
          ensure => 'disabled',
        }
        mikrotik_ip_service { 'api-ssl':
          ensure => 'enabled',
        }
        mikrotik_ip_service { 'www':
          addresses => [],  # TODO - DOES NOT WORK?
        }
        mikrotik_ip_service { 'ftp':
          port => 21,
        }        
        mikrotik_snmp { 'snmp':
          ensure          => disabled,
          contact         => "jubanoc@rcswimax.com",
          location        => "South Sudan",
          trap_version    => 1,
          trap_community  => "public",
          trap_generators => [],
          trap_targets    => [],
        }
        mikrotik_snmp_community { 'test_ro':
          ensure     => absent,
        }
        mikrotik_snmp_community { 'test_rw':
          ensure     => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
  
      # Agents: Puppet Device
      @result = run_puppet_device_on(agents)
      # Changes are not required here
      
      @result = run_puppet_device_on(agents)
      expect(@result.exit_code).to eq(0)    
    end
  end
end

require 'spec_helper_acceptance'

describe '/ip/firewall' do
  #before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create 3 new rules" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'Puppet Test 1':
          table       => 'filter',
          chain       => 'input',
          src_address => '1.1.1.1',
          action      => 'accept',
          #sequence    => '3',
        }
        
        mikrotik_firewall_rule { 'Puppet Test 2':
          table       => 'filter',
          chain       => 'input',
          src_address => '1.1.1.2',
          action      => 'accept',
          #sequence    => '3',
        }
        
        mikrotik_firewall_rule { 'Puppet Test 3':
          table       => 'filter',
          chain       => 'input',
          src_address => '1.1.1.3',
          action      => 'accept',
          #sequence    => '3',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update a rule" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'Puppet Test 1':
          table       => 'filter',
          chain       => 'input',
          src_address => '2.1.1.1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "delete a rule" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'Puppet Test 2':
           ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "ssh brute-force rules" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'SSH_JUMP':
          ensure           => present,                  # TODO - BUGFIX ???
          table            => 'filter',
          chain            => 'input',
          protocol         => 'tcp',
          dst_port         => '22',
          src_address_list => "!RCS_INFRA",
          action           => 'jump',
          jump_target      => 'SSH',
        }
        
        mikrotik_firewall_rule { 'SSH_DROP':
          ensure           => 'enabled',                  # TODO - BUGFIX ???
          table            => 'filter',
          chain            => 'SSH',
          src_address_list => 'ssh_block',
          action           => 'drop',
        }

        mikrotik_firewall_rule { 'SSH_STAGE3':
          ensure           => 'disabled',                  # TODO - BUGFIX ???
          table            => 'filter',
          chain            => 'SSH',
          connection_state => 'new',
          src_address_list => 'ssh_stage3',          
          action           => 'add-src-to-address-list',  
          address_list     => 'ssh_block',
        }
        
        mikrotik_firewall_rule { 'SSH_STAGE2':
          table                => 'filter',
          chain                => 'SSH',
          connection_state     => 'new',
          src_address_list     => 'ssh_stage2',          
          action               => 'add-src-to-address-list',
          address_list         => 'ssh_stage3',
          address_list_timeout => '1m',
        }
        
        mikrotik_firewall_rule { 'SSH_STAGE1':
          table                => 'filter',
          chain                => 'SSH',
          connection_state     => 'new',
          src_address_list     => 'ssh_stage1',
          action               => 'add-src-to-address-list',
          address_list         => 'ssh_stage2',            
          address_list_timeout => '1m',
        }
        
        mikrotik_firewall_rule { 'SSH_NEW':
          table                => 'filter',
          chain                => 'SSH',
          connection_state     => 'new',
          action               => 'add-src-to-address-list',
          address_list         => 'ssh_stage1',
          address_list_timeout => '1m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "clean up ssh brute-force rules" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { ['SSH_JUMP', 'SSH_DROP', 'SSH_STAGE3', 'SSH_STAGE2', 'SSH_STAGE1', 'SSH_NEW']:
          table  => 'filter',
          ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

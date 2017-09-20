require 'spec_helper_acceptance'

describe '/ip/firewall' do
  before { skip("Skipping this test for now") }
  
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

describe '/ip/firewall ordering' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "insert rules with simple ordering" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'unsorted_1':
          ensure           => present,
          table            => 'mangle',
          chain            => 'unsorted_1',
          src_address      => '1.1.1.1',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'rule_a':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 1,          
          src_address      => '2.2.2.2',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'rule_d':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 3,          
          src_address      => '2.2.2.4',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'unsorted_2':
          ensure           => present,
          table            => 'mangle',
          chain            => 'unsorted_2',
          src_address      => '1.1.1.2',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'rule_b':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 2,          
          src_address      => '2.2.2.1',
          action           => 'accept',
        }   
  
        mikrotik_firewall_rule { 'rule_f':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 5,          
          src_address      => '2.2.2.7',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'rule_e':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 4,          
          src_address      => '2.2.2.5',
          action           => 'accept',
        }
          
        mikrotik_firewall_rule { 'unsorted_3':
          ensure           => present,
          table            => 'mangle',
          chain            => 'unsorted_3',
          src_address      => '1.1.1.3',
          action           => 'accept',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "insert more rules" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'rule_c':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 3,          
          src_address      => '2.2.2.3',
          action           => 'accept',
        }
  
        mikrotik_firewall_rule { 'rule_g':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 7,          
          src_address      => '2.2.2.6',
          action           => 'accept',
        }       
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "move some rules" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'rule_a':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 2,
        }
              
        mikrotik_firewall_rule { 'rule_b':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 1,
        }
          
        mikrotik_firewall_rule { 'rule_g':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 6,
        }          
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "move rule to start of chain" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'rule_f':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 1,
        }    
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "move rule to end of chain" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { 'rule_b':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 7,
        }           
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "complex move" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_firewall_rule { 'unsorted_1':
          ensure           => absent,
          table            => 'mangle',
          chain            => 'unsorted_1',
        }
        
        mikrotik_firewall_rule { 'unsorted_2':
          ensure           => absent,
          table            => 'mangle',
          chain            => 'unsorted_2',
        }
        
        mikrotik_firewall_rule { 'unsorted_3':
          ensure           => absent,
          table            => 'mangle',
          chain            => 'unsorted_3',
        }
          
        mikrotik_firewall_rule { 'rule_f':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 2,
        }      
  
        mikrotik_firewall_rule { 'rule_g':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 3,
        } 
        
        mikrotik_firewall_rule { 'rule_e':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 4,
        } 
        
        mikrotik_firewall_rule { 'rule_d':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 5,
        } 
        
        mikrotik_firewall_rule { 'rule_c':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 6,
        } 
  
        mikrotik_firewall_rule { 'rule_a':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 7,
        } 
        
        mikrotik_firewall_rule { 'rule_b':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 8,
        } 
  
        mikrotik_firewall_rule { 'rule_h':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 9,          
          src_address      => '2.2.2.0/30',
          action           => 'accept',
        }  
  
        mikrotik_firewall_rule { 'rule_i':
          ensure           => present,
          table            => 'mangle',
          chain            => 'order_test',
          chain_order      => 1,          
          src_address      => '2.2.2.8',
          action           => 'accept',
        }  
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "cleanup" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_firewall_rule { ['unsorted_1', 'unsorted_2', 'unsorted_3']:
          ensure => absent,  
          table  => 'mangle',        
        }
  
        mikrotik_firewall_rule { ['rule_a', 'rule_b', 'rule_c', 'rule_d', 'rule_e', 'rule_f', 'rule_g', 'rule_h', 'rule_i']:
          ensure => absent,   
          table  => 'mangle',       
        }     
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

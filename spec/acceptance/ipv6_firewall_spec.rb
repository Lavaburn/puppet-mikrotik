require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe '/ipv6/firewall' do
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
  
  describe '/ipv6/firewall/address-list' do  
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_address_list { 'MT_TEST_LIST':
            ensure => 'absent',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "create new list" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_address_list { 'MT_TEST_LIST':
            addresses => [
              '2001:db8:100::/64',
              '2001:db8:200::/64',
            ],
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "add entries to list" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_address_list { 'MT_TEST_LIST':
            addresses => [
              '2001:db8:100::/64',
              '2001:db8:200::/64',
              '2001:db8:300::/64',
              '2001:db8:400::/64',
            ],
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "remove entries from list" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_address_list { 'MT_TEST_LIST':
            addresses => [
              '2001:db8:200::/64',
              '2001:db8:400::/64',
            ],
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "delete list" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_address_list { 'MT_TEST_LIST':
            ensure => 'absent',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/ipv6/firewall generic' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_firewall_rule { ['Puppet Test 1', 'Puppet Test 2', 'Puppet Test 3']:
            ensure => absent, 
            table  => 'filter',          
          }
          
          mikrotik_ipv6_firewall_rule { ['SSH_JUMP', 'SSH_DROP', 'SSH_STAGE3', 'SSH_STAGE2', 'SSH_STAGE1', 'SSH_NEW']:
            ensure => absent, 
            table  => 'filter',          
          }
          
          mikrotik_ipv6_firewall_rule { ['unsorted_1', 'unsorted_2', 'unsorted_3']:
            ensure => absent, 
            table  => 'mangle',          
          }
    
          mikrotik_ipv6_firewall_rule { ['rule_a', 'rule_b', 'rule_c', 'rule_d', 'rule_e', 'rule_f', 'rule_g', 'rule_h', 'rule_i']:
            ensure => absent,    
            table  => 'mangle',       
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "create 3 new rules" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_firewall_rule { 'Puppet Test 1':
            ensure      => present,
            table       => 'filter',
            chain       => 'input',
            src_address => '2001:db8:1111::/64',
            action      => 'accept',
            #sequence    => '3',
          }
          
          mikrotik_ipv6_firewall_rule { 'Puppet Test 2':
            ensure      => enabled,
            table       => 'filter',
            chain       => 'input',
            src_address => '2001:db8:1112::/64',
            action      => 'accept',
            #sequence    => '3',
          }
          
          mikrotik_ipv6_firewall_rule { 'Puppet Test 3':
            ensure      => disabled,
            table       => 'filter',
            chain       => 'input',
            src_address => '2001:db8:1113::/64',
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
          mikrotik_ipv6_firewall_rule { 'Puppet Test 1':
            table       => 'filter',
            chain       => 'input',
            src_address => '2001:db8:2111::/64',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "delete a rule" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_firewall_rule { 'Puppet Test 2':
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
          mikrotik_ipv6_firewall_rule { 'SSH_JUMP':
            ensure           => present,
            table            => 'filter',
            chain            => 'input',
            protocol         => 'tcp',
            dst_port         => '22',
            src_address_list => "!RCS_INFRA",
            action           => 'jump',
            jump_target      => 'SSH',
          }
          
          mikrotik_ipv6_firewall_rule { 'SSH_DROP':
            ensure           => 'enabled',
            table            => 'filter',
            chain            => 'SSH',
            src_address_list => 'ssh_block',
            action           => 'drop',
          }
  
          mikrotik_ipv6_firewall_rule { 'SSH_STAGE3':
            ensure           => 'disabled',
            table            => 'filter',
            chain            => 'SSH',
            connection_state => 'new',
            src_address_list => 'ssh_stage3',          
            action           => 'add-src-to-address-list',  
            address_list     => 'ssh_block',
          }
          
          mikrotik_ipv6_firewall_rule { 'SSH_STAGE2':
            table                => 'filter',
            chain                => 'SSH',
            connection_state     => 'new',
            src_address_list     => 'ssh_stage2',          
            action               => 'add-src-to-address-list',
            address_list         => 'ssh_stage3',
            address_list_timeout => '1m',
          }
          
          mikrotik_ipv6_firewall_rule { 'SSH_STAGE1':
            table                => 'filter',
            chain                => 'SSH',
            connection_state     => 'new',
            src_address_list     => 'ssh_stage1',
            action               => 'add-src-to-address-list',
            address_list         => 'ssh_stage2',            
            address_list_timeout => '1m',
          }
          
          mikrotik_ipv6_firewall_rule { 'SSH_NEW':
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
          mikrotik_ipv6_firewall_rule { ['SSH_JUMP', 'SSH_DROP', 'SSH_STAGE3', 'SSH_STAGE2', 'SSH_STAGE1', 'SSH_NEW']:
            table  => 'filter',
            ensure => 'absent',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/ipv6/firewall ordering' do    
    context "insert rules with simple ordering" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ipv6_firewall_rule { 'unsorted_1':
            ensure           => present,
            table            => 'mangle',
            chain            => 'unsorted_1',
            src_address      => '2001:db8:1111::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'rule_a':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 1,          
            src_address      => '2001:db8:2222::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'rule_d':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 3,          
            src_address      => '2001:db8:2224::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'unsorted_2':
            ensure           => present,
            table            => 'mangle',
            chain            => 'unsorted_2',
            src_address      => '2001:db8:1112::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'rule_b':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 2,          
            src_address      => '2001:db8:2221::/64',
            action           => 'accept',
          }   
    
          mikrotik_ipv6_firewall_rule { 'rule_f':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 5,          
            src_address      => '2001:db8:2227::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'rule_e':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 4,          
            src_address      => '2001:db8:2225::/64',
            action           => 'accept',
          }
            
          mikrotik_ipv6_firewall_rule { 'unsorted_3':
            ensure           => present,
            table            => 'mangle',
            chain            => 'unsorted_3',
            src_address      => '2001:db8:1113::/64',
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
          mikrotik_ipv6_firewall_rule { 'rule_c':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 3,          
            src_address      => '2001:db8:2223::/64',
            action           => 'accept',
          }
    
          mikrotik_ipv6_firewall_rule { 'rule_g':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 7,          
            src_address      => '2001:db8:2226::/64',
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
          mikrotik_ipv6_firewall_rule { 'rule_a':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 2,
          }
                
          mikrotik_ipv6_firewall_rule { 'rule_b':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 1,
          }
            
          mikrotik_ipv6_firewall_rule { 'rule_g':
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
          mikrotik_ipv6_firewall_rule { 'rule_f':
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
          mikrotik_ipv6_firewall_rule { 'rule_b':
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
          mikrotik_ipv6_firewall_rule { 'unsorted_1':
            ensure           => absent,
            table            => 'mangle',
            chain            => 'unsorted_1',
          }
          
          mikrotik_ipv6_firewall_rule { 'unsorted_2':
            ensure           => absent,
            table            => 'mangle',
            chain            => 'unsorted_2',
          }
          
          mikrotik_ipv6_firewall_rule { 'unsorted_3':
            ensure           => absent,
            table            => 'mangle',
            chain            => 'unsorted_3',
          }
            
          mikrotik_ipv6_firewall_rule { 'rule_f':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 2,
          }      
    
          mikrotik_ipv6_firewall_rule { 'rule_g':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 3,
          } 
          
          mikrotik_ipv6_firewall_rule { 'rule_e':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 4,
          } 
          
          mikrotik_ipv6_firewall_rule { 'rule_d':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 5,
          } 
          
          mikrotik_ipv6_firewall_rule { 'rule_c':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 6,
          } 
    
          mikrotik_ipv6_firewall_rule { 'rule_a':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 7,
          } 
          
          mikrotik_ipv6_firewall_rule { 'rule_b':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 8,
          } 
    
          mikrotik_ipv6_firewall_rule { 'rule_h':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 9,          
            src_address      => '2001:db8:2220::/64',
            action           => 'accept',
          }  
    
          mikrotik_ipv6_firewall_rule { 'rule_i':
            ensure           => present,
            table            => 'mangle',
            chain            => 'order_test',
            chain_order      => 1,          
            src_address      => '2001:db8:2228::/64',
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
          mikrotik_ipv6_firewall_rule { ['unsorted_1', 'unsorted_2', 'unsorted_3']:
            ensure => absent,  
            table  => 'mangle',        
          }
    
          mikrotik_ipv6_firewall_rule { ['rule_a', 'rule_b', 'rule_c', 'rule_d', 'rule_e', 'rule_f', 'rule_g', 'rule_h', 'rule_i']:
            ensure => absent,   
            table  => 'mangle',       
          }     
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
end
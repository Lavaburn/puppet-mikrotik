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
end

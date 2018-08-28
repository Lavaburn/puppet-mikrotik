require 'spec_helper_acceptance'

describe '/system/logging' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_logging_rule { 'info_!dhcp_myRemote':
          ensure => absent,
          topics => ['info','!dhcp'],
          action => 'myRemote',
        }
          
        mikrotik_logging_rule { 'debug_!dhcp_myRemote':
          ensure => absent,
          topics => ['info','!dhcp'],
          action => 'myRemote',
        }
        
        mikrotik_logging_action { 'myRemote':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 2
  end  
  
  context "log to new action" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_logging_action { 'myRemote':
          remote      => '105.235.209.12',
          remote_port => 5143,
          src_address => '172.20.111.69',
        }
        
        mikrotik_logging_rule { 'debug_!dhcp_myRemote':
          topics => ['debug','!dhcp'],
          action => 'myRemote',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update rule and action" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_logging_action { 'myRemote':
          src_address => '105.235.209.44',
        }
        
        mikrotik_logging_rule { 'debug_!dhcp_myRemote':
          ensure => absent,
          topics => ['debug','!dhcp'],
          action => 'myRemote',
        }
        
        mikrotik_logging_rule { 'info_!dhcp_myRemote':
          topics => ['info','!dhcp'],
          action => 'myRemote',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "clean up" do
    it 'should update master' do
      site_pp = <<-EOS        
        mikrotik_logging_rule { 'info_!dhcp_myRemote':
          ensure => absent,
          topics => ['info','!dhcp'],
          action => 'myRemote',
        }
        
        mikrotik_logging_action { 'myRemote':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "incomplete rule" do
    it 'should update master' do
      site_pp = <<-EOS                   
        mikrotik_logging_rule { 'debug_remote':
          topics => ['debug'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'a faulty device run'
  end
end

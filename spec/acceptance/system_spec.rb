require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe '/system' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  describe '/system generic' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_system { 'system':
            identity      => 'mikrotik',
            timezone      => 'Europe/Brussels',
            ntp_enabled   => false,
            ntp_primary   => '193.190.147.153',
            ntp_secondary => '195.200.224.66',
          }   
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
  
    context "correct settings" do
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_system { 'system':
            identity      => 'chr_dude1',
            timezone      => 'Africa/Juba',
            ntp_enabled   => true,
            ntp_primary   => '193.190.253.212',
            ntp_secondary => '79.132.231.103',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
        
    context "with wrong title" do
      it 'should update master' do
        site_pp = <<-EOS       
          mikrotik_system { 'systemTEST':
            identity      => 'mikrotik',
            timezone      => 'Europe/Brussels',
            ntp_enabled   => false,
            ntp_primary   => '193.190.147.153',
            ntp_secondary => '195.200.224.66',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'a faulty device run'
    end
  end

  describe '/system/script' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_script { 'script1': 
            ensure => absent,
          }
        
          mikrotik_schedule { 'daily_run_script1': 
            ensure => absent,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 2
    end  
    
    context "script with schedule" do
      it 'should update master' do
        site_pp = <<-EOS    
          mikrotik_script { 'script1': 
            policies => ['read'],
            source   => '/log info message="Hello World!"',   
          }
        
          mikrotik_schedule { 'daily_run_script1': 
            ensure   => disabled,
            interval => '1h',
            policies => ['read'],
            on_event => 'script1',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "update script and schedule" do
      it 'should update master' do
        site_pp = <<-EOS    
          mikrotik_script { 'script1': 
            policies => ['write'],
            source   => '/log info message="Hello World 2 !"',   
          }
        
          mikrotik_schedule { 'daily_run_script1': 
            ensure   => enabled,
            interval => '1d',
            policies => ['read', 'write'],
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "disable schedule" do
      it 'should update master' do
        site_pp = <<-EOS    
          mikrotik_schedule { 'daily_run_script1': 
            ensure => disabled
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "enable schedule" do      
      it 'should update master' do
        site_pp = <<-EOS    
          mikrotik_schedule { 'daily_run_script1': 
            ensure => enabled
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end  
  end

  describe '/system/logging' do  
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
end
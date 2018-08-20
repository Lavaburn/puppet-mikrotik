require 'spec_helper_acceptance'

describe '/system' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

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

  context "script with schedule" do
    it 'should update master' do
      site_pp = <<-EOS    
        mikrotik_script { 'script1': 
          policies => ['read'],
          source   => '/log info message="Hello World!"',   
        }
      
        mikrotik_schedule { 'daily_run_script1': 
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
    before { skip("Skipping this test for now") }
      
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
  
  context "add package source" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '105.235.209.43':
          username => 'upgrade',
          password => 'upgradeME',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update package source" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '105.235.209.43':
          username => 'upgrade2',
          password => 'upgradeME2',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "remove package source" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '105.235.209.43':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
end

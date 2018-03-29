require 'spec_helper_acceptance'

describe '/ppp' do
  #before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'aaa':
          use_radius     => false,
          accounting     => false,
          interim_update => '1m',
        }
  
        mikrotik_ppp_profile { ['profile1', 'profile2']:
          ensure => absent,
        }
                  
        mikrotik_ppp_server { ['pptp', 'l2tp']:
          ensure => 'disabled',          
        }
        
        mikrotik_ppp_secret  { ['ppp_user1', 'ppp_user2']:
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 4
  end  
  
  context "create ppp profiles" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_profile { 'profile1':
          # Defaults
        }
             
        mikrotik_ppp_profile { 'profile2':
          local_address   => '192.168.0.1',
          incoming_filter => 'PPP_FILTER',
          address_list    => 'PPP_USERS',
          use_compression => 'yes',
          use_encryption  => 'required',
          session_timeout => '1h',
          rate_limit      => '256k/1M',   
          only_one        => 'no',       
        }      
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update ppp profile" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_profile { 'profile1':
          outgoing_filter => 'PPP_FILTER_OUT',
          use_compression => 'no',
          idle_timeout    => '10m',          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "correct aaa settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'aaa':
          use_radius     => true,
          accounting     => true,
          interim_update => '5m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable aaa" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'aaa':
          use_radius => false,
          accounting => false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'myAAA2':
          use_radius     => true,
          interim_update => '10m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end

  context "pptp server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_server { 'pptp':
          authentication  => ['pap', 'chap'],
          default_profile => 'profile1',
        }
        
        mikrotik_ppp_server { 'l2tp':
          ensure          => 'present',
          authentication  => ['chap', 'mschap1'],
          default_profile => 'profile1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'    
  end

  context "l2tp server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_server { 'pptp':
          ensure => 'disabled',
        }
      
        mikrotik_ppp_server { 'l2tp':
          ensure          => 'enabled',
          authentication  => ['mschap1'],
          default_profile => 'profile2',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'    
  end

  context "server with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_server { 'myPPPServer':
          ensure => enabled,# TODO: BUG - does not enforce if ensure != enabled/disabled !!!
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'a faulty device run'  
  end

  context "create secret" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_secret  { 'ppp_user1':
          password       => 'password',
          service        => 'any',
          profile        => 'profile1',
          local_address  => '192.168.10.1',  
          remote_address => '192.168.10.2',      
        }
        
        mikrotik_ppp_secret  { 'ppp_user2':
          ensure         => 'disabled',
          password       => 'password',
          service        => 'pptp',
          routes         => ['192.168.11.0/24', '192.168.12.0/24'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update secret" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_secret  { 'ppp_user1':
          ensure         => 'present',
          password       => 'password2',    
          profile        => 'profile2',
          local_address  => '192.168.10.5',  
          remote_address => '192.168.10.6',  
        }
        
        mikrotik_ppp_secret  { 'ppp_user2':
          ensure         => 'enabled',
          service        => 'l2tp',
          routes         => ['192.168.11.1/24'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable secret" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_secret  { 'ppp_user1':
          ensure => 'disabled',
        }
        
        mikrotik_ppp_secret  { 'ppp_user2':
          ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

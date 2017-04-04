require 'spec_helper_acceptance'

describe '/user' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "create user groups" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user_group { 'admin1':
          # Defaults
        }
             
        mikrotik_user_group { 'admin2':
          policy => ['read', 'ssh', 'winbox']
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "correct aaa settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user_aaa { 'aaa':
          use_radius     => true,
          accounting     => true,
          interim_update => '5m',
          default_group  => 'write',
          exclude_groups => ['admin1', 'admin2']
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable aaa" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user_aaa { 'aaa':
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
        mikrotik_user_aaa { 'myAAA2':
          use_radius     => true,
          interim_update => '10m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
  
  context "create user" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user { 'testuser1':
          password  => 'password',
          group     => 'admin1',
          addresses => ['192.168.0.0/24'],
        }

      # TODO
#        mikrotik_user_sshkey { 'testuser1':
#          public_key => 'TODO',
#        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update user" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user { 'testuser1':
          password  => 'password2',
          group     => 'admin2',
          addresses => ['192.168.0.0/24', '192.168.1.0/24'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable user" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user { 'testuser1':
          ensure    => 'disabled',
          addresses => ['192.168.1.0/24'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

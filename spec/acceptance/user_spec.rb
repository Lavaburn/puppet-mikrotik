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
end

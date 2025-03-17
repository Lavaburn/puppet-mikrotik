require 'spec_helper_acceptance'

# Should be tested on:
# ROS v6.37 - OK
# ROS v6.49 - OK
describe '/radius' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-backup':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "add server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-backup':
          services => ['ppp'],
          address  => '1.2.3.4',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "configure server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-backup':
          services    => ['ppp', 'hotspot'],
          auth_port   => 18120,
          acct_port   => 18130,
          secret      => 'password',
          src_address => '1.2.3.5',
          timeout     => '3s',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "remove server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-backup':
          ensure => absent,
          services => ['ppp'],
          address  => '1.2.3.4',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

# Should be tested on:
# ROS v6.49 - OK
describe 'v7: /radius' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "add server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          services => ['ppp'],
          address  => '1.2.3.4',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "configure server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          services    => ['ppp', 'hotspot'],
          auth_port   => 18120,
          acct_port   => 18130,
          secret      => 'password',
          src_address => '1.2.3.5',
          timeout     => '3s',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          ensure   => disabled,
          services => ['ppp', 'hotspot']
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "enable server with radsec and msg auth" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          ensure           => enabled,
          services         => ['ppp', 'hotspot'],
          protocol         => 'radsec',
          require_msg_auth => 'yes-for-request-resp'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "remove server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-v7':
          ensure   => absent,
          services => ['ppp'],
          address  => '1.2.3.4',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

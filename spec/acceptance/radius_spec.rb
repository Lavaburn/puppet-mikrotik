require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
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
  
  # TODO remove
end

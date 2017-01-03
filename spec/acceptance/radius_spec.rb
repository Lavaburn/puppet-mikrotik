require 'spec_helper_acceptance'

describe '/radius' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "add server" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_radius_server { 'auth-backup':
          services => ['ppp'],
          address  => '105.235.209.36',
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
          auth_port   => 18121,
          acct_port   => 18131,
          secret      => 'password',
          src_address => '105.235.209.44',
          timeout     => '3s',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  # TODO remove
end

require 'spec_helper_acceptance'

# ROS v7 ONLY !
describe 'v7: /mpls/ldp' do
  before { skip("Skipping this test for now") }

  include_context 'testnodes defined'

  context "reset configuration" do     
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_ldp_instance { 'RCS':
          ensure => absent,
        }
        
        mikrotik_mpls_ldp_instance { 'ldp':
          ensure => disabled,               # Only 1 active per VRF !
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run after failures', 1
  end
  
    
  context "add second instance" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_ldp_instance { 'RCS':
          ensure => enabled,
          lsr_id => '105.235.209.45',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run'
  end
  
  context "remove second instance" do
    it 'should update master' do
      site_pp = <<-EOS
      mikrotik_mpls_ldp_instance { 'RCS':
          ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'an idempotent device run'
  end
end

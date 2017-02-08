require 'spec_helper_acceptance'

describe '/mpls' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "update ldp" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_ldp { 'ldp':
          ensure            => enabled,
          lsr_id            => '105.235.209.44',
          transport_address => '172.20.111.69',
          loop_detect       =>  true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
# TODO - exist code = 0 ??? => Find other way to detect error...
#  context "with ensure absent" do
#    it 'should update master' do
#      site_pp = <<-EOS
#        mikrotik_mpls_ldp { 'ldp':
#          ensure => 'absent',
#        }
#      EOS
#      
#      set_site_pp_on_master(site_pp)
#    end
#  
#    it_behaves_like 'a faulty device run'
#  end
#  
#  context "with wrong title" do
#    it 'should update master' do
#      site_pp = <<-EOS
#        mikrotik_mpls_ldp { 'myLDP2':
#        
#        }
#      EOS
#      
#      set_site_pp_on_master(site_pp)
#    end
#  
#    it_behaves_like 'a faulty device run'
#  end
end

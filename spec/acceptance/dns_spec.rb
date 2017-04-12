require 'spec_helper_acceptance'

describe '/ip/dns' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "correct settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dns { 'dns':
          servers               => ['105.235.209.31','208.67.222.222'],
          allow_remote_requests => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable remote requests" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dns { 'dns':
          allow_remote_requests => false,
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
#        mikrotik_dns { 'dns':
#          ensure => 'absent',
#        }
#      EOS
#      
#      set_site_pp_on_master(site_pp)
#    end
#  
#    it_behaves_like 'a faulty device run'
#  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_dns { 'myDNS2':
          servers               => ['105.235.209.31','208.67.222.222'],
          allow_remote_requests => false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

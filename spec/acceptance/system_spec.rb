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
end

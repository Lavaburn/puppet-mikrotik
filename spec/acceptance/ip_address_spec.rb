require 'spec_helper_acceptance'

describe '/ip/address' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create new address" do
    it 'should update master' do
      site_pp = <<-EOS      
        mikrotik_ip_address { '192.168.201.1/24':
          interface => 'ether1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

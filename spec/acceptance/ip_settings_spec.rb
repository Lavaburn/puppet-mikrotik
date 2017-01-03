require 'spec_helper_acceptance'

describe '/ip settings' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "rp-filter=loose" do
    it 'should update master' do
      site_pp = <<-EOS                
        mikrotik_ip_settings { 'ip':
          rp_filter => 'loose',
        }    
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "rp-filter=strict" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_ip_settings { 'ip':
          rp_filter => 'strict',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS               
        mikrotik_ip_settings { 'MyIP2':
          rp_filter => 'no',
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

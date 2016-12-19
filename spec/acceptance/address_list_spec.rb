require 'spec_helper_acceptance'

describe '/ip/firewall/address-list' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "create new list" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_address_list { 'MT_TEST_LIST':
          addresses => [
            '1.1.1.0/24',
            '1.1.2.0/24',
          ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "add entries to list" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_address_list { 'MT_TEST_LIST':
          addresses => [
            '1.1.1.0/24',
            '1.1.2.0/24',
            '1.1.4.0/24',
            '1.1.3.0/24',
          ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "remove entries from list" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_address_list { 'MT_TEST_LIST':
          addresses => [
            '1.1.2.0/24',
            '1.1.4.0/24',
          ],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "delete list" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_address_list { 'MT_TEST_LIST':
          ensure => 'absent',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

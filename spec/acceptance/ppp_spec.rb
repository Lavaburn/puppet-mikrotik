require 'spec_helper_acceptance'

describe '/ppp' do
  #before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "create ppp profiles" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_profile { 'profile1':
          # Defaults
        }
             
        mikrotik_ppp_profile { 'profile2':
          local_address   => '192.168.0.1',
          incoming_filter => 'PPP_FILTER',
          address_list    => 'PPP_USERS',
          use_compression => 'yes',
          use_encryption  => 'required',
          session_timeout => '1h',
          rate_limit      => '256k/1M',   
          only_one        => 'no',       
        }      
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update ppp profile" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_profile { 'profile1':
          outgoing_filter => 'PPP_FILTER_OUT',
          use_compression => 'no',
          idle_timeout    => '10m',          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "correct aaa settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'aaa':
          use_radius     => true,
          accounting     => true,
          interim_update => '5m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable aaa" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ppp_aaa { 'aaa':
          use_radius => false,
          accounting => false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_user_aaa { 'myAAA2':
          use_radius     => true,
          interim_update => '10m',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

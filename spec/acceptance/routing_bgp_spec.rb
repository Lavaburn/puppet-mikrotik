require 'spec_helper_acceptance'

describe '/routing/bgp' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "instance creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_instance { 'RCS':
          as                          => '37406',
          router_id                   => '105.235.209.44',
          redistribute_connected      => true,
          redistribute_static         => true,
          out_filter                  => 'RCS_OUT',
          client_to_client_reflection => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "instance update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_instance { 'RCS':
          redistribute_connected      => false,
          redistribute_static         => false,
          out_filter                  => 'RCS_OUT1',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "peers creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'dude1':
          instance           => 'RCS',
          peer_address       => '105.235.209.43',
          peer_as            => '37406',
          source             => 'ether1',       
          out_filter         => 'RCS_PEER_OUT',
          in_filter          => 'RCS_PEER_IN',
          route_reflect      =>  true,
          default_originate  => 'always',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "peers update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_bgp_peer { 'dude1':
          source             => '105.235.209.44',   
          out_filter         => 'RCS_PEER_OUT2',
          in_filter          => 'RCS_PEER_IN2',
          route_reflect      =>  false,
          default_originate  => 'if-installed',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

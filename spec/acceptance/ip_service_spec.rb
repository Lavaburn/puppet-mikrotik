require 'spec_helper_acceptance'

describe '/ip/service' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_service { 'telnet':
          ensure => 'disabled',
        }
        mikrotik_ip_service { 'api-ssl':
          ensure => 'enabled',
        }
        mikrotik_ip_service { 'www':
          addresses => [],
        }
        mikrotik_ip_service { 'ftp':
          port => 21,
        }  
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "valid changes" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_service { 'telnet':
          ensure => 'enabled',
        }
        mikrotik_ip_service { 'api-ssl':
          ensure => 'disabled',
        }
        mikrotik_ip_service { 'www':
          addresses => ['83.101.0.0/16', '172.16.0.0/12'],
        }
        mikrotik_ip_service { 'ftp':
          port      => 2121,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "addresses clearing" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_ip_service { 'www':
          addresses => [],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end

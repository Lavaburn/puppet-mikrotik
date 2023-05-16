require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe 'IPv4 Generic' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  describe '/ip settings' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_ip_settings { 'ip':
            rp_filter => 'no',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
   
      it_behaves_like 'an idempotent device run after failures', 1
    end  
  
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
  
  describe '/ip/address' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_ip_address { ['192.168.201.1/24', '192.168.202.1/24']:
            ensure => absent,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "create new address" do
      it 'should update master' do
        site_pp = <<-EOS      
          mikrotik_ip_address { '192.168.201.1/24':
            interface => 'ether1',
          }
          
          mikrotik_ip_address { '192.168.202.1/24':
            ensure    => disabled,
            interface => 'ether1',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "enable address" do
      it 'should update master' do
        site_pp = <<-EOS           
          mikrotik_ip_address { '192.168.202.1/24':
            ensure    => enabled,
            interface => 'ether1',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/ip/dns' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
        mikrotik_dns { 'dns':
          servers               => ['8.8.8.8','8.8.4.4'],
          allow_remote_requests => false,
        }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
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

  describe '/ip/service' do  
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
end
require 'spec_helper_acceptance'

describe '/ip settings' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

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

describe '/ipv6 settings' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_ipv6_settings { 'ipv6':
          accept_redirects             => true,
          accept_router_advertisements => 'yes-if-forwarding-disabled',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
 
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "accept_redirects=false" do
    it 'should update master' do
      site_pp = <<-EOS                
        mikrotik_ipv6_settings { 'ipv6':
          accept_redirects => false,
        }    
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "accept_router_advertisements=no" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_ipv6_settings { 'ipv6':
          accept_router_advertisements => 'no',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS               
        mikrotik_ipv6_settings { 'MyIP6':
          accept_router_advertisements => 'no',
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

describe '/interface bridge settings' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_interface_bridge_settings { 'bridge':
          allow_fast_path           => true,
          use_ip_firewall           => false,
          use_ip_firewall_for_pppoe => false,
          use_ip_firewall_for_vlan  => false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
 
    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "enable firewall for bridged PPPoE" do
    it 'should update master' do
      site_pp = <<-EOS                
        mikrotik_interface_bridge_settings { 'bridge':
          use_ip_firewall_for_pppoe => true,
        }    
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end # EXPECT FAILURE !!

  context "enable firewall for bridged VLAN" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_interface_bridge_settings { 'bridge':
          use_ip_firewall           => true,
          use_ip_firewall_for_pppoe => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "disable fastpath" do
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_interface_bridge_settings { 'bridge':
          allow_fast_path => false,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS               
        mikrotik_interface_bridge_settings { 'MyBridge2':
          allow_fast_path => true,
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

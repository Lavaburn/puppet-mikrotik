require 'spec_helper_acceptance'

describe 'v7: Routing OSPF' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_v7_ospf_interface_template { 'test-ether1':
          ensure => absent,        
        }
         
        mikrotik_ospf_area { 'BORDER3':
          ensure => absent,        
        }
    
        mikrotik_v7_ospf_static_neighbor { '1.2.3.4%ether1':
          ensure => absent,
        }

        mikrotik_v7_ospf_instance { 'PUPPET':
          ensure => absent,        
        }
  
        mikrotik_v7_ospf_instance { 'PUPPETv3':
          ensure  => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 6
  end  

  describe '/routing/ospf/instance' do
    context "instance creation" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_v7_ospf_instance { 'PUPPET':
            ensure                 => disabled,
            originate_default     => 'always',
            redistribute          => ['connected', 'static'],
            out_filter             => 'PUPPET_PEER_OUT',
            in_filter              => 'PUPPET_PEER_IN',            
          }
          
          mikrotik_v7_ospf_instance { 'PUPPETv3':
            ensure  => enabled,
            version => 3       
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "instance update" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_ospf_instance { 'PUPPET':
            ensure                 => enabled,
            originate_default     => 'if-installed',
            redistribute          => ['connected', 'static', 'bgp'],
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end

  describe '/routing/ospf/area' do
    context "area creation" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_ospf_area { 'BORDER3':
            area_id  => '0.0.1.63',
            instance => 'PUPPET',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "area update" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_ospf_area { 'BORDER3':
            area_id  => '0.0.0.63',
            instance => 'PUPPET',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end

  describe '/routing/ospf/interface-template' do
    context "interface creation" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_ospf_interface_template { 'test-ether1':
            area       => 'BORDER3',
            interfaces => ['ether1'],
            cost       => 100,
            priority   => 20,
            passive    => true,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "interface update" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_ospf_interface_template { 'test-ether1':
            cost     => 10,
            priority => 200,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/routing/ospf/static-neighbor' do
    context "neighbor creation" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_ospf_static_neighbor { '1.2.3.4%ether1':
            area => 'BORDER3',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "neighbor update" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_ospf_static_neighbor { '1.2.3.4%ether1':
            poll_interval => '5m',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "neighbor disable" do
      it 'should update master' do
        site_pp = <<-EOS      
          mikrotik_v7_ospf_static_neighbor { '1.2.3.4%ether1':
            ensure => disabled,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end  
  end  
end

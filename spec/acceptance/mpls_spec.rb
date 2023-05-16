require 'spec_helper_acceptance'

# Tested on both ROS v6 and v7
describe '/mpls' do
  before { skip("Skipping this test for now") }
    
  include_context 'testnodes defined'

  describe '/mpls/ldp' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
        mikrotik_mpls_ldp_instance { 'ldp':
            ensure              => disabled,
            lsr_id              => '0.0.0.0',
            transport_addresses => ['0.0.0.0'],
            loop_detect         =>  false,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "update ldp" do
      it 'should update master' do
        site_pp = <<-EOS
        mikrotik_mpls_ldp_instance { 'ldp':
            ensure              => enabled,
            lsr_id              => '105.235.209.44',
            transport_addresses => ['172.20.111.69'],
            loop_detect         =>  true,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/mpls/ldp/interface' do
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            ensure => absent,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "create ldp interface" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "update ldp interface" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            hello_interval           => '10s',
            hold_time                => '30s',
            transport_address        => '10.0.2.15',
            accept_dynamic_neighbors => false,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "disable ldp interface" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            ensure => disabled,          
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "enable ldp interface" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            ensure => enabled,          
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "remove ldp interface" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_mpls_ldp_interface { 'ether1':
            ensure => absent,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end
end

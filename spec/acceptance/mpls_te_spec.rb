require 'spec_helper_acceptance'

describe '/mpls te' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_te { 'TE_TUNNEL':
          ensure => absent,
        }

        mikrotik_mpls_te_path { 'dynamic':
          ensure => absent,
        }
        
        mikrotik_mpls_te_path { 'static':
          ensure => absent,
        }
      
        mikrotik_mpls_te_interface { 'ether1':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    #it_behaves_like 'an idempotent device run after failures', 1
    it_behaves_like 'an idempotent device run'
  end  
  
  context "create te interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_te_interface { 'ether1':
          bandwidth => '10000000',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update te interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_te_interface { 'ether1':
          bandwidth => '20000000',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

    
  context "create te path" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_te_path { 'dynamic':
          
        }
        
        mikrotik_mpls_te_path { 'static':
          use_cspf     => false,
          hops         => [ '1.1.1.1:loose', '1.1.1.2:loose', '1.1.1.3:loose' ],
          record_route => true,
          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update te path" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_mpls_te_path { 'dynamic':
          record_route => true,
        }
        
        mikrotik_mpls_te_path { 'static':
          hops         => [ '1.1.1.1:strict', '1.1.1.2:strict', '1.1.1.3:strict' ],
          record_route => false,
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "create te tunnel" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_te { 'TE_TUNNEL':
          from_address    => '2.2.2.1',
          to_address      => '2.2.2.2',
          bandwidth       => '20000000',
          primary_path    => 'static',
          secondary_paths => [ 'dynamic' ],
          record_route    => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update te tunnel" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_interface_te { 'TE_TUNNEL':
          ensure                 => enabled,
          bandwidth_limit        => '90',
          auto_bandwidth_range   => '10000000-30000000',
          auto_bandwidth_reserve => '10',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end
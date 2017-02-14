require 'spec_helper_acceptance'

describe '/routing/ospf' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "instance creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_instance { 'RCS':
          router_id              => '105.235.209.44',
          distribute_default     => 'always-as-type-1',
          redistribute_connected => 'as-type-2',
          redistribute_static    => 'as-type-2',
          out_filter             => 'RCS_PEER_OUT',
          in_filter              => 'RCS_PEER_IN',
          metric_connected       => 100,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "instance update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_instance { 'RCS':
          distribute_default     => 'if-installed-as-type-1',
          redistribute_connected => 'as-type-1',
          redistribute_static    => 'as-type-1',
          metric_connected       => 50,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "area creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_area { 'BORDER3':
          area_id  => '0.0.1.63',
          instance => 'RCS',
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
          instance => 'RCS',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "network creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_network { '105.235.209.44/32':
          area  => 'backbone',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "network update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_network { '105.235.209.44/32':
          area  => 'BORDER3',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "interface creation" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_interface { 'ether1':
          cost     => 100,
          priority => 20,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "interface update" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_ospf_interface { 'ether1':
          cost     => 10,
          priority => 200,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end
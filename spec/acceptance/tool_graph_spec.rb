require 'spec_helper_acceptance'

describe '/tool/graphing' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_graph_interface { 'all':
          ensure => absent,
        }
        
        mikrotik_graph_resource { 'resource':
          ensure => absent,
        }
        
        mikrotik_graph_queue { 'all':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 3
  end  

  context "interface" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_graph_interface { 'all':
          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "resource" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_graph_resource { 'resource':
          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "queue" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_graph_queue { 'all':
          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "filtering allowed" do
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_graph_interface { 'all':
          allow => '83.101.0.0/16'
        }
        mikrotik_graph_resource { 'resource':
          allow => '83.101.0.0/16'
        }
        mikrotik_graph_queue { 'all':
          allow => '83.101.0.0/16'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  # TODO - exist code = 0 ??? => Find other way to detect error...
#  context "with wrong title" do
#    it 'should update master' do
#      site_pp = <<-EOS
#        mikrotik_graph_resource { 'resources2':
#          allow => '83.101.0.0/16'
#        }
#      EOS
#
#      set_site_pp_on_master(site_pp)
#    end
#
#    it_behaves_like 'a faulty device run'
#  end
end

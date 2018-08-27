require 'spec_helper_acceptance'

describe '/system/upgrade' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  before(:each) do
    # Upgrade Source
    @upgrade_source = get_upgrade_source
  end 
  
  # Package Source
  context "add package source" do      
#    before { skip("Skipping this test for now") }
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '#{@upgrade_source[:hostname]}':
          username => 'testuser',
          password => '#{@upgrade_source[:password]}',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "update package source" do      
#    before { skip("Skipping this test for now") }
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '#{@upgrade_source[:hostname]}':
          username => '#{@upgrade_source[:username]}',
          password => 'unchanged',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  # Sanity Check
  context "wrong package" do      
#    before { skip("Skipping this test for now") }   # OK
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '8.0.1':
          ensure => downloaded,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end

  context "package present" do      
#    before { skip("Skipping this test for now") }   # OK
    
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version1]}':
          ensure => present,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an empty device run'
  end

  context "package absent" do      
#    before { skip("Skipping this test for now") }   # OK
    
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '8.0.1':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an empty device run'
  end

  context "package removal" do      
#    before { skip("Skipping this test for now") }   # OK
    
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version1]}':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'a faulty device run'
  end

  # Action: Download + Reboot
  context "install package and reboot" do      
#    before { skip("Skipping this test for now") }   # OK
    
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version2]}':
          ensure       => installed,
          force_reboot => true
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "download installed package" do      
#    before { skip("Skipping this test for now") }
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version2]}':
          ensure => downloaded,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an empty device run'
  end
  
  # Action: Download and forget forced reboot
  context "download package" do      
#    before { skip("Skipping this test for now") }   # OK
    
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version1]}':
          ensure => downloaded,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "install package without force" do      
#    before { skip("Skipping this test for now") }   # OK
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade { '#{@upgrade_source[:version1]}':
          ensure => installed,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a changing device run'
  end
  
  # Package Source Cleanup
  context "remove package source" do
#    before { skip("Skipping this test for now") }
      
    it 'should update master' do
      site_pp = <<-EOS            
        mikrotik_upgrade_source { '#{@upgrade_source[:hostname]}':
          ensure => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
end

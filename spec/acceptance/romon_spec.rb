require 'spec_helper_acceptance'

describe '/tool/romon' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon { 'romon':
          ensure  => disabled,
          secrets => [],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "correct settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon { 'romon':
          ensure  => enabled,
          secrets => ["secret1", "secret2"],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable romon" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon { 'romon':
          ensure  => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "enable romon" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon { 'romon':
          ensure  => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon { 'myRMN':
          secrets => ["secret1", "secret2"],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
end

describe '/tool/romon/port' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS  
        mikrotik_romon_port { 'all':
          ensure  => enabled,
          forbid  => false,
          cost    => 100,
          secrets => [],
        }
        
        mikrotik_romon_port { 'ether1':
          ensure  => absent,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  
  
  context "add interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon_port { 'ether1':
          ensure  => enabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "change settings for ether1" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon_port { 'ether1':
          ensure  => enabled,
          forbid  => false,
          secrets => ["overwrite1"],
          cost    => 200,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "change settings for all" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon_port { 'all':
          ensure  => enabled,
          forbid  => true,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "disable interface" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_romon_port { 'ether1':
          ensure  => disabled,
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end  
end

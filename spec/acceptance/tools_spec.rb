require 'spec_helper_acceptance'

describe '/tool/e-mail' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_email { 'email':
          server       => '0.0.0.0',
          from_address => '<>',
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "with valid settings" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_email { 'email':
          server          => '105.235.209.19',
          from_address    => 'chr_dude1@rcswimax.com',
          enable_starttls => true,
          username        => 'test', 
          password        => 'test',          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "without STARTTLS" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_email { 'email':
          enable_starttls => false,          
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "with wrong title" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_email { 'MyE-mail':
          server       => '127.0.0.1',
          from_address => 'jubanoc@rcswimax.com',
        }
      EOS

      set_site_pp_on_master(site_pp)
    end

    it_behaves_like 'a faulty device run'
  end
end

describe '/tool/netwatch' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'

  context "reset configuration" do      
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_netwatch { '8.8.4.4':
          ensure => 'absent'
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run after failures', 1
  end  

  context "create watches" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_netwatch { '8.8.4.4':
          down_script => '/log info Host Down',
          up_script   => '/log info Host Up',
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "update watches" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_tool_netwatch { '8.8.4.4':
            ensure   => disabled,
            interval => '5m',
            timeout  => '5s',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
  context "enable watches" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_tool_netwatch { '8.8.4.4':
          ensure   => enabled,
        }        
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
end
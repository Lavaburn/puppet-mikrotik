require 'spec_helper_acceptance'

describe '/snmp' do
  before { skip("Skipping this test for now") }
  
  include_context 'testnodes defined'
  
  context "snmp normal config" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp { 'snmp':
          ensure   => enabled,
          contact  => "nicolas@rcswimax.com",
          location => "Juba",
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "snmp add community" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp_community { 'test_ro':
          ensure     => present,
        }
        mikrotik_snmp_community { 'test_rw':
          ensure       => present,
          write_access => true,          
          addresses    => ['105.235.208.0/22'],  
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end

  context "snmp update community" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp_community { 'test_ro':
          ensure => absent,
        }
        mikrotik_snmp_community { 'test_rw':
          addresses => ['172.16.0.0/22', '105.235.208.0/22'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
    
  context "snmp trap config" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp { 'snmp':
          trap_community  => "test_rw",
          trap_version    => 2,
          trap_generators => ["interfaces"],
          trap_targets    => ["105.235.209.12"],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "snmp clear community array" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp_community { 'test_rw':
          addresses => [],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "snmp clear traps array" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp { 'snmp':
          trap_generators => ["start-trap"],
          trap_targets    => [],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'an idempotent device run'
  end
  
  context "snmp invalid trap community" do
    it 'should update master' do
      site_pp = <<-EOS
        mikrotik_snmp { 'snmp':
          trap_targets => ['newcommunity'],
        }
      EOS
      
      set_site_pp_on_master(site_pp)
    end
  
    it_behaves_like 'a faulty device run'
  end
    
#  context "with ensure absent" do
#    it 'should update master' do
#      site_pp = <<-EOS
#        mikrotik_snmp { 'snmp':
#          ensure => 'absent',
#        }
#      EOS
#      
#      set_site_pp_on_master(site_pp)
#    end
#  
#    it_behaves_like 'a faulty device run'
#  end
#
#  context "with wrong title" do
#    it 'should update master' do
#      site_pp = <<-EOS
#        mikrotik_snmp { 'test':
#          ensure => 'enabled',  
#        }
#      EOS
#      
#      set_site_pp_on_master(site_pp)
#    end
#  
#    it_behaves_like 'a faulty device run'
#  end
end

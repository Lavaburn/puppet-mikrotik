require 'spec_helper_acceptance'

describe 'v7: Routing Filters' do
  before { skip("Skipping this test for now") }

  include_context 'testnodes defined'
  
  describe '/routing/filter/rule' do  
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_rule { ['rule1', 'rule2', 'rule3', 'rule4']:
            ensure => absent,          
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  
    
    context "create new filter" do
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_rule { 'rule1':
            chain => 'chain1',
            rule  => 'if ( bgp-med < 30 ) { accept }'
          }
          
          mikrotik_v7_routing_filter_rule { 'rule2':
            chain => 'chain2',
            rule  => 'if ( bgp-med < 50 ) { accept }'
          }
          
          mikrotik_v7_routing_filter_rule { 'rule3':
            ensure => disabled,
            chain  => 'chain1',
            rule   => 'if ( bgp-med < 70 ) { accept }'
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "update filter" do
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_rule { 'rule1':
            chain => 'chain1',
            rule  => 'if ( bgp-med < 30 ) { reject }'
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "enable/disable filter" do
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_rule { 'rule1':
            ensure => disabled,
            chain  => 'chain1',    
          }             
           
          mikrotik_v7_routing_filter_rule { 'rule3':
            ensure => enabled,
            chain  => 'chain1',
          }              
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "sort on insert" do
      it 'should update master' do
        site_pp = <<-EOS            
          mikrotik_v7_routing_filter_rule { 'rule4':
            chain       => 'chain1',
            chain_order => 2,
            rule        => 'if ( bgp-med < 90 ) { accept }'
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
    context "move filters" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_v7_routing_filter_rule { 'rule4':
            chain       => 'chain1',
            chain_order => 1,
          }
          mikrotik_v7_routing_filter_rule { 'rule3':
            chain       => 'chain1',
            chain_order => 2,
          }
          mikrotik_v7_routing_filter_rule { 'rule1':
            chain       => 'chain1',
            chain_order => 3,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  end

  describe '/routing/filter/select-rule' do  
    context "reset configuration" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_select_rule { ['select1', 'select2', 'select3', 'select4', 'select5', 'select6', 'select7']:
            ensure => absent,          
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run after failures', 1
    end  

    context "create new filter" do
      it 'should update master' do
        site_pp = <<-EOS      
          mikrotik_v7_routing_filter_select_rule { 'select1':
            ensure       => present,
            chain        => 'a', 
            do_group_num => 'distance>50',
          }
          
          mikrotik_v7_routing_filter_select_rule { 'select2':
            chain         => 'a', 
            do_group_prfx => 'dst>1.2.3.4',
          }
          
          mikrotik_v7_routing_filter_select_rule { 'select3':
            ensure  => disabled,
            chain   => 'a', 
            do_jump => 'b',
          }
        
          mikrotik_v7_routing_filter_select_rule { 'select6':
            chain   => 'b', 
            do_take => '1',
          }
        
          mikrotik_v7_routing_filter_select_rule { 'select7':
            chain    => 'b', 
            do_where => 'test',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end

    context "update filter" do
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_select_rule { 'select6':
            chain    => 'b', 
            do_where => 'test',
          }
        
          mikrotik_v7_routing_filter_select_rule { 'select7':
            chain   => 'b', 
            do_take => '1',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
    
    context "enable/disable filter" do
      it 'should update master' do
        site_pp = <<-EOS  
          mikrotik_v7_routing_filter_select_rule { 'select1':
            ensure => disabled,
            chain  => 'a', 
          }
          
          mikrotik_v7_routing_filter_select_rule { 'select3':
            ensure => enabled,
            chain  => 'a', 
          }            
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end

    context "sort on insert" do
      it 'should update master' do
        site_pp = <<-EOS
          mikrotik_v7_routing_filter_select_rule { 'select4':
            chain         => 'a', 
            chain_order   => 2,
            do_select_num => 'dst-len>largest-none-best',
          }
          
          mikrotik_v7_routing_filter_select_rule { 'select5':
            chain          => 'a', 
            chain_order    => 3,
            do_select_prfx => 'gw>smallest-none-worst',
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      it_behaves_like 'an idempotent device run'
    end
  
  
    context "move filters" do
      it 'should update master' do
        site_pp = <<-EOS          
          mikrotik_v7_routing_filter_select_rule { 'select5':
            chain       => 'a', 
            chain_order => 1,
          } 
          mikrotik_v7_routing_filter_select_rule { 'select4':
            chain       => 'a', 
            chain_order => 2,
          } 
          mikrotik_v7_routing_filter_select_rule { 'select3':
            chain       => 'a', 
            chain_order => 3,
          } 
          mikrotik_v7_routing_filter_select_rule { 'select2':
            chain       => 'a', 
            chain_order => 4,
          } 
          mikrotik_v7_routing_filter_select_rule { 'select1':
            chain       => 'a', 
            chain_order => 5,
          }
        EOS
        
        set_site_pp_on_master(site_pp)
      end
    
      #it_behaves_like 'an idempotent device run'
      it_behaves_like 'an idempotent device run after failures', 2    # Requires 2 runs to be idempotent ??
    end
  end
  
  describe '/routing/filter/num-list' do
    context "reset configuration" do       
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_num_list { ['asn1', 'asn2']:
            ensure => absent,
          }        
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run after failures', 1
    end  

    context "create new num lists" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_num_list { 'asn1':
            list  => 'asn_set1',
            range => '37406'
          }
          
          mikrotik_v7_routing_filter_num_list { 'asn2':
            list  => 'asn_set1',
            range => '20000-29999'
          }
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end

    context "update num lists" do      
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_num_list { 'asn2':
            list  => 'asn_set1',
            range => '20000-20099'
          }
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end

    context "disable num lists" do      
      it 'should update master' do
        site_pp = <<-EOS   
          mikrotik_v7_routing_filter_num_list { 'asn2':
            list   => 'asn_set1',
            ensure => disabled
          }
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end
  end
  
  describe '/routing/filter/community-list' do
    context "reset configuration" do       
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_community_list { ['communities1a', 'communities1b']:
            ensure => absent,          
          }        
          mikrotik_v7_routing_filter_community_list { ['communities2']:
            ensure => absent,      
            type   => 'extended',    
          }        
          mikrotik_v7_routing_filter_community_list { ['communities3']:
            ensure => absent,          
            type   => 'large',
          }        
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run after failures', 1
    end  

    context "create new community lists" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_community_list { 'communities1a':
            list        => 'communities1',
            communities => ['37406:1', '37406:2'],
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities1b':
            type   => 'normal',
            list   => 'communities1',
            regexp => '/37406:[1-5].*/',
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities2':
            type   => 'extended',
            list   => 'communities2',
            regexp => '/rt:37406:.*/',
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities3':
            type       => 'large',
            list        => 'communities3',
            communities => ['37406:37100:123'],
          }        
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end

    context "update community lists" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_community_list { 'communities1a':
            list        => 'communities1',
            communities => ['37406:101', '37406:102'],
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities1b':
            list   => 'communities1',
            regexp => '/37406:[6-9].*/',
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities2':
            type        => 'extended',
            list        => 'communities2',
            communities => ['rt:37100:123'],
          }
          
          mikrotik_v7_routing_filter_community_list { 'communities3':
            type   => 'large',
            list   => 'communities3',
            regexp => '/37406:37406:.*/',
          }        
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end

    context "disable community lists" do      
      it 'should update master' do
        site_pp = <<-EOS        
          mikrotik_v7_routing_filter_community_list { 'communities2':
            ensure => disabled,
            type   => 'extended',
            list   => 'communities2',
          }
        EOS

        set_site_pp_on_master(site_pp)
      end

      it_behaves_like 'an idempotent device run'
    end

    # TODO: Error on regex/list mixed
  end
end

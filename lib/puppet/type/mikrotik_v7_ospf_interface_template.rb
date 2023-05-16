Puppet::Type.newtype(:mikrotik_v7_ospf_interface_template) do
  apply_to_all

  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.create  
    end
    
    newvalue(:absent) do
      provider.destroy
    end
    
    newvalue(:enabled) do
      provider.create  
      provider.setState(:enabled)      
    end

    newvalue(:disabled) do
      provider.create  
      provider.setState(:disabled)
    end

    def retrieve
      provider.getState
    end
    
    def insync?(is)
      @should.each { |should| 
        case should
          when :present
            return (provider.getState != :absent)
          when :absent
            return (provider.getState == :absent)
          when :enabled                   
            return (provider.getState == :enabled)
          when :disabled                      
            return (provider.getState == :disabled)       
        end
      }
    end
  end
  
  newparam(:name) do
    desc 'OSPF Template name (see comments)'
    isnamevar
  end

  newproperty(:interfaces, :array_matching => :all) do
    desc 'The interfaces to which this template applies'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:area) do
    desc 'The OSPF Area'
  end

  newproperty(:networks, :array_matching => :all) do
    desc 'The networks to which this template applies'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:network_type) do
    desc 'The network type: broadcast, nbma, ptmp, ptmp-broadcast, ptp, ptp unnumbered, virtual link'
    newvalues(:broadcast, :nbma, :ptmp, 'ptmp-broadcast', :ptp, 'ptp-unnumbered', 'virtual-link')
    defaultto :broadcast
  end
  
  newproperty(:prefix_list) do
    desc 'The Prefix list to which this template applies'
  end
  
  newproperty(:instance_id) do
    desc 'The OSPF Instance ID ?'
  end
  
  newproperty(:cost) do
    desc 'The Cost of the OSPF interface(s).'
  end
  
  newproperty(:priority) do
    desc 'The Priority of the OSPF interface(s).'
  end
  
  newproperty(:passive) do
    desc 'Whether the interface(s) is/are passive (not participating in OSPF)'
    newvalues(false, true)
    defaultto false
  end

  newproperty(:authentication) do
    desc 'The authentication type (none, simple, md5, sha1, sha256, sha384, sha512)'
    newvalues(:simple, :md5, :sha1, :sha256, :sha384, :sha512)
  end
  
  newproperty(:authentication_key) do # authentication-key
    desc 'The key used for authentication.'
  end
  
  newproperty(:authentication_key_id) do # authentication-key-id
    desc 'Key ID used to calculate message digest (MD5 authentication). Common for all routers in area.'
  end

  newproperty(:vlink_transit_area) do
    desc 'The Vlink Transit Area?'
  end

  newproperty(:vlink_neighbor_id) do
    desc 'The Vlink Neighbor ID'
  end
end

Puppet::Type.newtype(:mikrotik_dhcp_server) do
  apply_to_device

  ensurable do
    defaultto :present
    
    newvalue(:present) do
      provider.create  
    end
    
    newvalue(:absent) do
      provider.destroy
    end
    
    newvalue(:enabled) do
      provider.setState(:enabled)      
    end

    newvalue(:disabled) do
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
    desc 'Name of the DHCP server instance'
    isnamevar
  end

  newproperty(:interface) do
    desc 'Interface to attach the DHCP server to'
  end  
  
  newproperty(:relay) do
    desc 'DHCP relay address'
  end
  
  newproperty(:lease_time) do
    desc 'Lease time for IP leases'
  end
  
  newproperty(:bootp_lease_time) do
    desc 'Lease time for BOOTP protocol'
  end
  
  newproperty(:address_pool) do
    desc 'IP address pool to lease addresses from'
  end
  
  newproperty(:src_address) do
    desc 'Source address of the DHCP responses'
  end
  
  newproperty(:delay_threshold) do
    desc 'Wait x time before replying to a request'
  end
  
  newproperty(:authoritative) do
    desc 'Whether/When to make the DHCP server authorative'
    newvalues('no', 'yes', 'after-2sec-delay', 'after-10sec-delay')
  end
  
  newproperty(:bootp_support) do
    desc 'Whether to enable BOOTP support'
    newvalues('none', 'static', 'dynamic')
  end
  
  newproperty(:lease_script) do
    desc 'Script to run on IP lease'
  end
  
  newproperty(:add_arp) do
    desc 'Whether to add dynamic ARP entry on lease'
    newvalues(true, false)
  end
  
  newproperty(:always_broadcast) do
    desc 'Whether to enable always broadcast (?)'
    newvalues(true, false)
  end
  
  newproperty(:use_radius) do
    desc 'Whether to use RADIUS server for IP lease authorization/accounting'
    newvalues(true, false)
  end
    
  # Not defined in winbox:
    #  conflict-detection -- 
    #  insert-queue-before -- 
    #  use-framed-as-classless -- 
end

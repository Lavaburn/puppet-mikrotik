require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_peer) do
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
    desc 'Peer description'
    isnamevar
  end

  newproperty(:address) do
    desc 'Address'
  end

  newproperty(:auth_method) do
    newvalues(*%w{eap-radius pre-shared-key pre-shared-key-xauth rsa-key rsa-signature rsa-signature-hybrid})
  end

  newproperty(:certificate) do
  end

  newproperty(:compatibility_options) do
  end

  newproperty(:dh_group, :array_matching => :all) do
    newvalues(*%w{ec2n155 ec2n185 ecp256 ecp384 ecp521 modp768 modp1024 modp1536 modp2048 modp4096 modp6144 modp8192})
  end

  newproperty(:dpd_interval) do
  end

  newproperty(:dpd_maximum_failures) do
  end

  newproperty(:enc_algorithm, :array_matching => :all) do
    newvalues(*%w{3des aes-128 aes-192 aes-256 blowfish camellia-128 camellia-192 camellia-256 des})
  end

  newproperty(:exchange_mode) do
    newvalues(*%w{aggresive base ike2 main main-l2tp})
  end

  newproperty(:generate_policy) do
    newvalues(*%w{no port-override port-strict})
  end

  newproperty(:hash_algorithm) do
    newvalues(:md5, :sha1, :sha256, :sha512)
  end  

  newproperty(:key) do
  end

  newproperty(:lifebytes) do
  end

  newproperty(:lifetime) do
  end

  newproperty(:local_address) do
  end

  newproperty(:mode_config) do
  end

  newproperty(:my_id) do
  end

  newproperty(:nat_traversal, boolean: true, parent: Puppet::Property::Boolean) do
  end

  newproperty(:notrack_chain) do
  end

  newproperty(:passive, boolean: true, parent: Puppet::Property::Boolean) do
    defaultto true
  end

  newproperty(:policy_template_group) do
  end

  newproperty(:port) do
  end

  newproperty(:proposal_check) do
    newvalues(:claim,:exact,:obey,:strict)
  end

  newproperty(:remote_certificate) do
  end

  newproperty(:remote_key) do
  end

  newproperty(:secret) do
  end

  newproperty(:send_initial_contact, boolean: true, parent: Puppet::Property::Boolean) do
    defaultto false
  end  

  newproperty(:xauth_login) do
  end

  newproperty(:xauth_password) do
  end

  autorequire(:mikrotik_ipsec_mode_config) { self[:mode_config] }

end

Puppet::Type.newtype(:mikrotik_ipsec_proposal) do
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
    desc 'Proposal name'
    isnamevar
  end

  newproperty(:auth_algorithms, array_matching: :all) do
    newvalues(:md5,:null,:sha1,:sha256,:sha512)
  end

  newproperty(:comment) do
  end

  newproperty(:enc_algorithms, array_matching: :all) do
    newvalues(*%w{
      3des des
      aes-128-cbc aes-128-ctr aes-128-gcm
      aes-192-cbc aes-192-ctr aes-192-gcm
      aes-256-cbc aes-256-ctr aes-256-gcm
      blowfish twofish
      camellia-128 camellia-192 camellia-256
      null
    })
  end
  
  newproperty(:lifetime) do
  end

  newproperty(:pfs_group) do
  end
end

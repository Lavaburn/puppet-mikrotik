Puppet::Type.newtype(:mikrotik_radius_server) do
  apply_to_all
  
  ensurable
  # TODO -ENABLED-
  
  newparam(:name) do
    desc 'The server description'
    isnamevar
  end
  
  newproperty(:address) do
    desc 'The server IP address.'
  end

  newproperty(:services, :array_matching => :all) do
    desc 'The services that the server will handle requests for.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:called_id) do
    desc 'The called ID.'
  end
  
  newproperty(:domain) do
    desc 'The domain to add to the username (?)'
  end
    
  newproperty(:secret) do
    desc 'The RADIUS shared secret.'
  end
  
  newproperty(:auth_port) do
    desc 'The RADIUS authentication port.'
  end
  
  newproperty(:acct_port) do
    desc 'The RADIUS accounting port.'
  end
  
  newproperty(:timeout) do
    desc 'The RADIUS timeout.'
  end
  
  newproperty(:accounting_backup) do
    desc 'Accounting backup (?)'
  end
  
  newproperty(:realm) do
    desc 'The realm that this server will listen for.'
  end
  
  newproperty(:src_address) do
    desc 'The source IP that will be used for requests.'
  end
end

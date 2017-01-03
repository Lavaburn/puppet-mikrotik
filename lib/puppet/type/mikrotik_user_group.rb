Puppet::Type.newtype(:mikrotik_user_group) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'Usergroup name'
    isnamevar
  end
  
  newproperty(:skin) do
    desc 'The skin to apply on the webinterface for these users.'
  end
  
  newproperty(:policy, :array_matching => :all) do
    desc 'The allowed permissions for the usergroup.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end    
  end
end

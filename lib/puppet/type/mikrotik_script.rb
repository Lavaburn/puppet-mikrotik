Puppet::Type.newtype(:mikrotik_script) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'Name of the script'
    isnamevar
  end
  
  newproperty(:policies, :array_matching => :all) do
    desc 'The permissions that the script is given.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:source) do
    desc 'The script itself'
  end
end

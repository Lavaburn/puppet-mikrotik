Puppet::Type.newtype(:mikrotik_interface_list) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The name of the interfaces list'
    isnamevar
  end
  
  newproperty(:members, :array_matching => :all) do
    desc 'Interfaces that belong to this list'
    
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

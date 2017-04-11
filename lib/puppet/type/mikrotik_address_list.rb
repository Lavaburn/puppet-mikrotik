Puppet::Type.newtype(:mikrotik_address_list) do  
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The address list name'
    isnamevar
  end

  newproperty(:addresses, :array_matching => :all) do
    desc 'The IP addresses assigned to the list'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

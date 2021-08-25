require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_interface_list) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The name of the interfaces list'
    isnamevar
  end
  
  newparam(:manage_members, boolean: true, parent: Puppet::Property::Boolean) do
    defaultto true
  end

  newproperty(:members, :array_matching => :all) do
    desc 'Interfaces that belong to this list'
    
    def insync?(is)
      if !resource.manage_members?
        true
      elsif is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:include, :array_matching => :all) do
    desc 'Other interface lists whose members are included in this list'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:exclude, :array_matching => :all) do
    desc 'Other interface lists whose members are excluded from this list'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

end

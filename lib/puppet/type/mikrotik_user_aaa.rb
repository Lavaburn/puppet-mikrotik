Puppet::Type.newtype(:mikrotik_user_aaa) do
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -aaa-'
    isnamevar
  end

  newproperty(:use_radius) do
    desc 'Whether to enable RADIUS for user authentication.'
    newvalues(true, false)
  end
  
  newproperty(:accounting) do
    desc 'Whether to enable RADIUS accounting.'
    newvalues(true, false)
  end
  
  newproperty(:interim_update) do
    desc 'The time period between RADIUS accounting updates.'
  end
  
  newproperty(:default_group) do
    desc 'The default group the user belongs to if not set by RADIUS (Mikrotik-Group).'
  end
  
  newproperty(:exclude_groups, :array_matching => :all) do
    desc 'The groups that can not be used by RADIUS.'
    
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort     
      else
        is == @should
      end
    end    
  end
end

Puppet::Type.newtype(:mikrotik_ppp_aaa) do
  apply_to_device

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
end

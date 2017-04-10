Puppet::Type.newtype(:mikrotik_ip_settings) do
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -ip-'
    isnamevar
  end

  newproperty(:rp_filter) do
    desc 'Setting for filtering Reverse Path. Can be -no-,-loose- or -strict-.'
    newvalues(:loose, :no, :strict)
  end
end

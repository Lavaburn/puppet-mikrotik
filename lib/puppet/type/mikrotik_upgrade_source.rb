Puppet::Type.newtype(:mikrotik_upgrade_source) do
  apply_to_all
  
  ensurable
  
  newparam(:name) do
    desc 'IP Address to fetch packages from'
    isnamevar
  end
  
  newproperty(:username) do
    desc 'Username for authentication on package source'
  end
  
  newparam(:password) do
    desc 'Password for authentication on package source'
  end
end

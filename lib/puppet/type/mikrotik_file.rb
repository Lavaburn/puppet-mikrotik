Puppet::Type.newtype(:mikrotik_file) do
  apply_to_all

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name) do
    desc 'Path to file'
    isnamevar
  end

  newproperty(:content) do
    desc 'Contents of file'
  end

end
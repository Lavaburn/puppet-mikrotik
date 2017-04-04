Puppet::Type.newtype(:mikrotik_user_sshkey) do
  apply_to_device
  
  ensurable

  newparam(:user) do
    desc 'The user that the public key belongs to'
    isnamevar
  end

  newparam(:public_key) do
    desc 'The SSH public key (DSA/RSA)'
  end
end

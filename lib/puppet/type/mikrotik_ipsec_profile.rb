require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_profile) do
  apply_to_all

  ensurable

  newparam(:name) do
    desc 'Profile description'
    isnamevar
  end

  newproperty(:dh_group, :array_matching => :all) do
    newvalues(*%w{ec2n155 ec2n185 ecp256 ecp384 ecp521 modp768 modp1024 modp1536 modp2048 modp3072 modp4096 modp6144 modp8192})
  end

  newproperty(:dpd_interval) do
  end

  newproperty(:dpd_maximum_failures) do
  end

  newproperty(:enc_algorithm, :array_matching => :all) do
    newvalues(*%w{3des aes-128 aes-192 aes-256 blowfish camellia-128 camellia-192 camellia-256 des})
  end

  newproperty(:hash_algorithm) do
    newvalues(:md5, :sha1, :sha256, :sha384, :sha512)
  end

  newproperty(:lifebytes) do
  end

  newproperty(:lifetime) do
  end

  newproperty(:nat_traversal, boolean: true, parent: Puppet::Property::Boolean) do
  end

  newproperty(:prf_algorithm) do
    newvalues(:auto, :sha1, :sha256, :sha384, :sha512)
    defaultto :auto
  end

  newproperty(:proposal_check) do
    newvalues(:claim,:exact,:obey,:strict)
  end
end

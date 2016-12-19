Puppet::Type.newtype(:mikrotik_firewall_rule) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc 'The unique identifier for the rule'
    isnamevar
  end

  newproperty(:table) do
    desc 'The table to which the rule applies (filter,nat,mangle)'
  end
  
  newproperty(:chain) do
    desc 'The chain to which the rule applies (input,output,filter,src-nat,...)'
  end
  
  newproperty(:src_address) do
    desc 'The source address to which the rule applies'
  end
  
  newproperty(:action) do
    desc 'The action the rule will take (accept,drop,...)'
  end
  
#  newproperty(:sequence) do
#    desc 'Sequence of the rule in the chain'
#  end
end

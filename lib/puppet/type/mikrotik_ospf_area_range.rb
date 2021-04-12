require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ospf_area_range) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'the network prefix of this range'
    isnamevar
  end
  
  newparam(:area) do
    desc 'The OSPF area associated with this range (name, not id)'
    isnamevar
  end
  
  newproperty(:cost) do
    desc "The cost of the summary LSA this range will create. 'calculated' will use the largest cost of all routes in the range" 
    newvalues(/^\d+$/,:calculated)
    defaultto :calculated
  end

  newproperty(:advertise, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Whether to create the summary LSA and advertise it to adjacent areas'
    defaultto true
  end

  newproperty(:comment) do
    desc "A comment describing this area range"
  end

  autorequire(:mikrotik_ospf_area) { self[:area] }

  # the actual 'title' of the resource is just the 'range' parameter;
  # the 'area' parameter must be set explicitly, not as part of the title.
  # This is exactly how the official 'package' resource works.
  def self.title_patterns
    [ [ /(.*)/, [ [:name] ] ] ]
  end
end

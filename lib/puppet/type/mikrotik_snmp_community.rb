Puppet::Type.newtype(:mikrotik_snmp_community) do
  ensurable
  
  newparam(:name) do
    desc 'SNMP community name'
    isnamevar
  end
  
  newproperty(:read_access) do
    desc 'Whether community provides read access.'
    newvalues(true, false)
    defaultto true
  end

  newproperty(:write_access) do
    desc 'Whether community provides write access.'
    newvalues(true, false)
    defaultto false    
  end
  
  newproperty(:addresses, :array_matching => :all) do
    desc 'The IP addresses allowed to use the community.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        if is == ['0.0.0.0/0'] and @should == []
          true
        else
          is.sort == @should.sort          
        end        
      else
        is == @should
      end
    end    
  end
end

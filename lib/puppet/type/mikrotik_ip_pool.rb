Puppet::Type.newtype(:mikrotik_ip_pool) do
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'IP pool name'
    isnamevar
  end

  newproperty(:ranges, :array_matching => :all) do
    desc 'IP ranges with addresses that belong to pool'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:next_pool) do
    desc 'Next IP pool to use if current pool is fully used.'
  end
end

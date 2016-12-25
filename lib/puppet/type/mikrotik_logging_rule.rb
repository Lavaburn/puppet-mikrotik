Puppet::Type.newtype(:mikrotik_logging_rule) do
  apply_to_device

  ensurable
  
  newparam(:name) do
    desc 'Mikrotik does not have a title ID for this object. Restricted to topic1,topic2_action'
    isnamevar
  end
  
  newproperty(:topics, :array_matching => :all) do
    desc 'The topics that will be filtered by this rule.'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort   
      else
        is == @should
      end
    end    
  end
  
  newproperty(:action) do
    desc 'The action that the logs will be sent to.'
  end
  
  newproperty(:prefix) do
    desc 'Prefix the logs by this string.'
  end
end

Puppet::Type.newtype(:mikrotik_tool_email) do
  apply_to_all
  
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -email-'
    isnamevar
  end
  
  newproperty(:server) do
    desc 'The SMTP server to use when using the e-mail tool.'
  end
  
  newproperty(:port) do
    desc 'The SMTP port to use when using the e-mail tool.'
  end
  
  newproperty(:username) do
    desc 'The SMTP username to use when using the e-mail tool.'
  end
  
  newproperty(:password) do
    desc 'The SMTP password to use when using the e-mail tool.'
  end

  newproperty(:from_address) do
    desc 'The E-mail address to send from when using the e-mail tool.'
  end

  newproperty(:enable_starttls) do
    desc 'Whether to enable STARTTLS when using the e-mail tool.'
    newvalues(true, false)
  end
end

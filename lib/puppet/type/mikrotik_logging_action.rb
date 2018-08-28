Puppet::Type.newtype(:mikrotik_logging_action) do
  apply_to_all

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'Logging action name'
    isnamevar
  end
  
  newproperty(:target) do
    desc 'The log target (type)'
    newvalues(:memory, :disk, :echo, :remote, :email)
    defaultto :remote
  end
  
  newproperty(:remote) do
    desc 'The hostname of the remote syslog server.'
  end
  
  newproperty(:remote_port) do
    desc 'The port of the remote syslog server.'
  end
  
  newproperty(:src_address) do
    desc 'The source IP that should be used in the remote syslog connection.'
  end
  
  newproperty(:bsd_syslog) do
    desc 'Whether to format the logs in BSD Syslog format'
    newvalues(true, false)
  end
  
  newproperty(:syslog_facility) do
    desc 'BSD Syslog Facility'
  end

  newproperty(:syslog_severity) do
    desc 'BSD Syslog Severity'
  end
    
  # 'memory':
    # memory-lines
    # memory-stop-on-full
  # 'disk':
    # disk-file-name
    # disk-lines-per-file
    # disk-file-count
    # disk-stop-on-full
  # 'echo':
    # remember
  # 'email':
    # email-to
    # email-start-tls
end

Puppet::Type.newtype(:mikrotik_ip_hotspot_profile) do
  apply_to_all
  
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'The Hotspot Profile name'
    isnamevar
  end
  
  newproperty(:dns_name) do
    desc 'DNS name of the HotSpot server'
  end
  
  newproperty(:hotspot_address) do
    desc 'IP address for HotSpot service'
  end
  
  newproperty(:html_directory) do
    desc 'Name of the directory, which stores the HTML servlet pages'
  end
  
  newproperty(:http_cookie_lifetime) do
    desc 'Validity time of HTTP cookies'
  end
  
  newproperty(:login_by, :array_matching => :all) do
    desc 'Authentication method to use'
  
    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:nas_port_type) do
    desc 'NAS Port Type ID (RADIUS)'
  end
  
  newproperty(:radius_accounting) do
    desc 'Enable or disable accounting'
    newvalues(true, false)
  end
  
  newproperty(:radius_default_domain) do
    desc 'When using split domain, set this domain if none set'
  end

  newproperty(:radius_interim_update) do
    desc 'Interim-Update time interval'
  end
  
  newproperty(:radius_location_id) do
    desc 'RADIUS Location ID'
  end
  
  newproperty(:radius_location_name) do
    desc 'RADIUS Location Name'
  end
  
  newproperty(:split_user_domain) do
    desc 'Whether to split username from domain name with user@domain or domain\user'
  end
  
  newproperty(:trial_uptime_limit) do
    desc 'Maximum uptime in trial mode'
  end
  
  newproperty(:trial_uptime_reset) do
    desc 'When to reset user from using trial again'
  end
  
  newproperty(:trial_user_profile) do
    desc 'User Profile to apply to trial user.'
  end
  
  newproperty(:use_radius) do
    desc 'Use RADIUS for AAA'
    newvalues(true, false)
  end
end

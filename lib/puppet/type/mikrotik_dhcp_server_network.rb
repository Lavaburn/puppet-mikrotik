Puppet::Type.newtype(:mikrotik_dhcp_server_network) do
  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:address) do
    desc 'Network address (CIDR subnet) in use by a DHCP server instance'
    isnamevar
  end

  newproperty(:gateways, :array_matching => :all) do
    desc 'Default Gateways to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:netmask) do
    desc 'Netmask to use for IP lease (?)'
  end
  
  newproperty(:dns_servers, :array_matching => :all) do
    desc 'DNS servers to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:domain) do
    desc 'Domain name to advertise when leasing IP'
  end

  newproperty(:wins_servers, :array_matching => :all) do
    desc 'WINS servers to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:ntp_servers, :array_matching => :all) do
    desc 'NTP servers to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:caps_managers, :array_matching => :all) do
    desc 'CAPS managers to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:next_server) do
    desc 'IP of the next DHCP server to use'
  end

  newproperty(:boot_file_name) do
    desc 'File name to use for BOOTP protocol'
  end
  
  newproperty(:dhcp_options, :array_matching => :all) do
    desc 'Extra DHCP options to advertise when leasing IP'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
  
  newproperty(:dhcp_option_sets, :array_matching => :all) do
    desc 'Option set to use for advertising extra DHCP options'

    def insync?(is)
      if is.is_a?(Array) and @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end
end

require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_upgrade).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods
  
  def exists?
    [:present, :installed, :downloaded].include?(@property_hash[:ensure]) 
  end
  
  def self.instances
    Puppet::Provider::Mikrotik_Api::command("/system/upgrade/refresh")
    
    sleep(10)
    
    packages = Puppet::Provider::Mikrotik_Api::get_all("/system/upgrade")
    # Puppet.debug("/system/upgrade: #{packages.inspect}")

    instances = packages.collect { |package| 
      if package['name'] =~ /routeros-.*/
        getPackage(package)  
      end
    }
    instances    
  end
  
  def self.getPackage(package)
    new(
      :ensure => :present,
      :name   => package['version'],
      :state  => package['status'].to_sym
    )
  end

  def flush
    Puppet.debug("Upgrading Firmware to #{resource[:name]}")

    # Standard features that won't work here
    if @property_flush[:ensure] == :present and @original_values.empty?
      raise "Firmware #{resource[:name]} is not available from auto upgrade source!"      
    end
    
    if @property_flush[:ensure] == :absent
        raise "It is not possible to remove firmware from auto upgrade sources!"      
    end

    # Download Only
    if @property_hash[:state] == :downloaded
      if @original_values[:state] == :installed
        Puppet.debug("Get State: "+getState)
        Puppet.warning("Firmware #{resource[:name]} is already installed!")
     end         
      
      if @original_values[:state] == :available
        download(resource[:name])        
      end  
    end
    
    # Reboot
    if @property_hash[:state] == :installed
      if @original_values[:state] == :available
        download(resource[:name])        
        reboot(resource[:force_reboot])
      end

      if @original_values[:state] == :downloaded
        reboot(resource[:force_reboot])
      end
    end
  end

  def download(version)
    Puppet.info("Downloading firmware #{version}")
    
    packages = Puppet::Provider::Mikrotik_Api::get_all("/system/upgrade")
    packages.each { |package| 
      if package['name'] =~ /routeros-.*/ and package['version'] == version    
        params = {}
        params[".id"] = package['.id']
            
        Puppet::Provider::Mikrotik_Api::command("/system/upgrade/download", params)
          
        downloading(version)
      end
    }
  end
  
  def downloading(version)
    downloading = true
    
    while (downloading) do
      downloading = false
      
      packages = Puppet::Provider::Mikrotik_Api::get_all("/system/upgrade")
      packages.each { |package| 
        if package['name'] =~ /routeros-.*/ and package['version'] == version
          if package['status'] == 'downloading'
            Puppet.debug("Firmware download is #{package['completed']}% completed. Sleeping for 5 seconds")  
                      
            downloading = true
            
            sleep(5)
          end
        end
      }
    end
  end
  
  def reboot(force)
    if (force)
      Puppet.info("Rebooting device to install firmware")

      Puppet::Provider::Mikrotik_Api::command("/system/reboot")
      sleep(60)
    else
      Puppet.warning( "Firmware installation requires rebooting the device. Puppet is not allowed to reboot device without 'force_reboot => true'.")
    end
  end
end
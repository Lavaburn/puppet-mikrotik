require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_package).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods
  
  def self.instances    
    packages = Puppet::Provider::Mikrotik_Api::get_all("/system/package")
    instances = packages.collect { |package| getPackage(package) }
    instances    
  end
  
  def self.getPackage(package)    
    if package['disabled'] == "true" and package['scheduled'] == ""
      state = :disabled
    else
      state = :enabled
    end
    
    new(
      :ensure => :present,
      :state  => state,
      :name   => package['name']
    )
  end

  def flush
    lookup = {}
    lookup["name"] = resource[:name]

    id_list = Puppet::Provider::Mikrotik_Api::lookup_id("/system/package", lookup)
    id_list.each do |id|
      params = { ".id" => id }
      
      if @property_hash[:state] == :disabled
        Puppet.debug("Disabling Package #{resource[:name]}")
  
        result = Puppet::Provider::Mikrotik_Api::disable("/system/package", params)        
      elsif @property_hash[:state] == :enabled
        Puppet.debug("Enabling Package #{resource[:name]}")

        result = Puppet::Provider::Mikrotik_Api::enable("/system/package", params)
      end
    end

    # Reboot
    reboot(resource[:force_reboot])
  end

  def reboot(force)
    if (force)
      Puppet.info("Rebooting device to install package")
      Puppet::Provider::Mikrotik_Api::command("/system/reboot")
      sleep(60)
    else
      Puppet.warning( "Package enabling requires rebooting the device. Puppet is not allowed to reboot device without 'force_reboot => true'.")
    end
  end
end

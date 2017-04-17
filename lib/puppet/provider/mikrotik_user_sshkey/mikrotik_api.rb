require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_user_sshkey).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    ssh_keys = Puppet::Provider::Mikrotik_Api::get_all("/user/ssh-keys")
    instances = ssh_keys.collect { |ssh_key| sshKey(ssh_key) }
    instances
  end

  def self.sshKey(data)
    new(
      :ensure => :present,
      :name   => data['name']
    )
  end

  def flush
    Puppet.debug("Flushing User SSH Key #{resource[:name]}")

    params = {}
    params["user"] = resource[:name]
    params["public-key-file"] = 'TODO'

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    # TODO - transfer file and import...
  end  
end

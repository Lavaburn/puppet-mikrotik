require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_file).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :net_scp

  mk_resource_methods

  def self.instances
    files = Puppet::Provider::Mikrotik_Api::get_all("/file")
    files.map {|data| file(data)}
  end

  def self.file(data)
    new(
      ensure: :present, 
      name: data['name'],
      content: data['contents'],
    )
  end

  def flush
    if resource[:ensure] == :present
      c = self.class.transport.connection
      data = StringIO.new(resource['content'])
      path = resource['name']
      Net::SCP.upload!(c.host,c.user,data,path,ssh: {password: c.pass})
    else
      Puppet::Provider::Mikrotik_Api::remove("/file", {'numbers' => resource['name']})
    end
  end

end
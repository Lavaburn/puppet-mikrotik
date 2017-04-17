require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_script).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances    
    scripts = Puppet::Provider::Mikrotik_Api::get_all("/system/script")
    instances = scripts.collect { |script| systemScript(script) }    
    instances
  end
  
  def self.systemScript(data)        
    new(
      :ensure   => :present,
      :name     => data['name'],
      :policies => data['policy'].split(','),  
      :source   => data['source']
    )
  end

  def flush
    Puppet.info("Flushing Script #{resource[:name]}")
    
    params = {}
    params["name"] = resource[:name]
    params["policy"] = resource[:policies].join(',') if ! resource[:policies].nil?
    params["source"] = resource[:source] if ! resource[:source].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/system/script", params, lookup)
  end  
end

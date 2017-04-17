require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ppp_aaa).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances
    instances = []
      
    aaa = Puppet::Provider::Mikrotik_Api::get_all("/ppp/aaa")
    aaa.each do |data|
      object = pppAAASettings(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.pppAAASettings(data)        
    new(
      :name           => 'aaa',
      :use_radius     => data['use-radius'],
      :accounting     => data['accounting'],
      :interim_update => data['interim-update']
    )
  end

  def flush
    Puppet.debug("Flushing PPP AAA")
    
    if (@property_hash[:name] != 'aaa') 
      raise "There is only one set of PPP AAA settings. Title (name) should be -aaa-"
    end
    
    update = {}
    update["use-radius"]     = (resource[:use_radius].to_s) if ! resource[:use_radius].nil?
    update["accounting"]     = (resource[:accounting].to_s) if ! resource[:accounting].nil?
    update["interim-update"] = resource[:interim_update] if ! resource[:interim_update].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/ppp/aaa", update)
  end
end

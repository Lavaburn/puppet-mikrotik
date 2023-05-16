require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_snmp_community).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances    
    communities = Puppet::Provider::Mikrotik_Api::get_all("/snmp/community")
    Puppet.debug("/snmp/community: #{communities.inspect}")
    instances = communities.collect { |community| snmpCommunity(community) }
    
    instances
  end
  
  def self.snmpCommunity(data)
    addresses = data['addresses'].nil? ? nil : data['addresses'].split(',')

    # Required for newer versions of v6 (>=v6.45 ??)
    if addresses.count == 1 and addresses.first == "::/0" 
      addresses = []
    end
    
    new(
      :ensure       => :present,
      :name         => data['name'],
      :read_access  => data['read-access'],
      :write_access => data['write-access'],
      :addresses    => addresses
    )
  end

  def flush
    Puppet.debug("Flushing SNMP Community #{resource[:name]}")
      
    params = {}
    params["name"] = resource[:name]
    params["read-access"] = resource[:read_access] if ! resource[:read_access].nil?
    params["write-access"] = resource[:write_access] if ! resource[:write_access].nil?
    params["addresses"] = resource[:addresses].join(',') if ! resource[:addresses].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/snmp/community", params, lookup)
  end  
end
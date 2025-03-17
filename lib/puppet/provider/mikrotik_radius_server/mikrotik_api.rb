require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_radius_server).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    servers = Puppet::Provider::Mikrotik_Api::get_all("/radius")

    instances = []
    servers.each { |server|
      obj = radiusServer(server)
      if obj != nil
        instances << obj
      end
    }
    instances
  end

  def self.radiusServer(data)
    if ! data['comment'].nil?
      services = data['service'].split(',')
      
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end   
      
      new(
        :ensure            => :present,
        :state             => state,
        :name              => data['comment'],
        :address           => data['address'],
        :services          => services,
        :called_id         => data['called-id'],
        :domain            => data['domain'],
        :secret            => data['secret'],
        :auth_port         => data['authentication-port'],
        :acct_port         => data['accounting-port'],
        :timeout           => data['timeout'],
        :accounting_backup => data['accounting-backup'],
        :realm             => data['realm'],
        :src_address       => data['src-address'],
        :require_msg_auth  => data['require-message-auth'],
        :protocol          => data['protocol']
      )
    end
  end

  def flush
    Puppet.debug("Flushing RADIUS Server #{resource[:name]}")
      
    params = {}
    params["comment"] = resource[:name]

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["address"] = resource[:address] if ! resource[:address].nil?
    if ! resource[:services].nil?
      params["service"] = resource[:services].join(',')
    end 
    
    params["called-id"] = resource[:called_id] if ! resource[:called_id].nil?
    params["domain"] = resource[:domain] if ! resource[:domain].nil?
    params["secret"] = resource[:secret] if ! resource[:secret].nil?
    params["authentication-port"] = resource[:auth_port] if ! resource[:auth_port].nil?
    params["accounting-port"] = resource[:acct_port] if ! resource[:acct_port].nil?

    params["timeout"] = resource[:timeout] if ! resource[:timeout].nil?
    params["accounting-backup"] = resource[:accounting_backup] if ! resource[:accounting_backup].nil?
    params["realm"] = resource[:realm] if ! resource[:realm].nil?
    params["src-address"] = resource[:src_address] if ! resource[:src_address].nil?

    params["protocol"] = resource[:protocol] if ! resource[:protocol].nil?
    params["require-message-auth"] = resource[:require_msg_auth] if ! resource[:require_msg_auth].nil?

    lookup = {}
    lookup["comment"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/radius", params, lookup)
  end
end

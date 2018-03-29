require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ppp_secret).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    secrets = Puppet::Provider::Mikrotik_Api::get_all("/ppp/secret")
    instances = secrets.collect { |secret| secretObject(secret) }
    instances
  end

  def self.secretObject(data)
    routes = data['routes'].nil? ? nil : data['routes'].split(',')

    if data['disabled'] == 'true'
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure           => :present,
      :state            => state,
      :name             => data['name'],
      :password         => data['password'],
      :service          => data['service'],
      :caller_id        => data['caller-id'],
      :profile          => data['profile'],
      :local_address    => data['local-address'],
      :remote_address   => data['remote-address'],
      :routes           => routes,
      :limit_bytes_in   => data['limit-bytes-in'],
      :limit_bytes_out  => data['limit-bytes-out']
    )
  end

  def flush
    Puppet.debug("Flushing PPP Secret #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = true
    elsif @property_hash[:state] == :enabled
      params["disabled"] = false
    end

    params["name"] = resource[:name]
    params["password"] = resource[:password] if ! resource[:password].nil?
    params["service"] = resource[:service] if ! resource[:service].nil?
    params["caller-id"] = resource[:caller_id] if ! resource[:caller_id].nil?
    params["profile"] = resource[:profile] if ! resource[:profile].nil?
    params["local-address"] = resource[:local_address] if ! resource[:local_address].nil?
    params["remote-address"] = resource[:remote_address] if ! resource[:remote_address].nil?
    params["routes"] = resource[:routes].join(',') if ! resource[:routes].nil?
    params["limit-bytes-in"] = resource[:limit_bytes_in] if ! resource[:limit_bytes_in].nil?
    params["limit-bytes-out"] = resource[:limit_bytes_out] if ! resource[:limit_bytes_out].nil?

    lookup = {}
    lookup["name"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ppp/secret", params, lookup)
  end
end

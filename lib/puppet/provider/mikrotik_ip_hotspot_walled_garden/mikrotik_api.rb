require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_hotspot_walled_garden).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    entries = Puppet::Provider::Mikrotik_Api::get_all("/ip/hotspot/walled-garden")
    entries.each do |entry|
      object = wgEntry(entry)
      if object != nil
        instances << object
      end
    end

    instances
  end

  # Only entries with a comment are managed; dynamic entries belong to the hotspot itself
  def self.wgEntry(data)
    if data['comment'] != nil && data['dynamic'] != "true"
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end

      new(
        :ensure      => :present,
        :state       => state,
        :name        => data['comment'],
        :action      => data['action'],
        :dst_host    => data['dst-host'],
        :dst_port    => data['dst-port'],
        :http_path   => data['path'],
        :http_method => data['method'],
        :server      => data['server'],
        :src_address => data['src-address']
      )
    end
  end

  def flush
    Puppet.debug("Flushing Walled Garden entry #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["comment"] = resource[:name]
    params["action"] = resource[:action] if !resource[:action].nil?
    params["dst-host"] = resource[:dst_host] if !resource[:dst_host].nil?
    params["dst-port"] = resource[:dst_port] if !resource[:dst_port].nil?
    params["path"] = resource[:http_path] if !resource[:http_path].nil?
    params["method"] = resource[:http_method] if !resource[:http_method].nil?
    params["server"] = resource[:server] if !resource[:server].nil?
    params["src-address"] = resource[:src_address] if !resource[:src_address].nil?

    lookup = {}
    lookup["comment"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/hotspot/walled-garden", params, lookup)
  end
end

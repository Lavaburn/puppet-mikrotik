require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ip_hotspot_walled_garden_ip).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    entries = Puppet::Provider::Mikrotik_Api::get_all("/ip/hotspot/walled-garden/ip")
    entries.each do |entry|
      object = wgIpEntry(entry)
      if object != nil
        instances << object
      end
    end

    instances
  end

  # Only entries with a comment are managed; dynamic entries belong to the hotspot itself
  def self.wgIpEntry(data)
    if data['comment'] != nil && data['dynamic'] != "true"
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end

      new(
        :ensure           => :present,
        :state            => state,
        :name             => data['comment'],
        :action           => data['action'],
        :dst_address      => data['dst-address'],
        :dst_address_list => data['dst-address-list'],
        :protocol         => data['protocol'],
        :dst_port         => data['dst-port'],
        :server           => data['server'],
        :src_address      => data['src-address']
      )
    end
  end

  def flush
    Puppet.debug("Flushing Walled Garden IP entry #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["comment"] = resource[:name]
    params["action"] = resource[:action] if !resource[:action].nil?
    params["dst-address"] = resource[:dst_address] if !resource[:dst_address].nil?
    params["dst-address-list"] = resource[:dst_address_list] if !resource[:dst_address_list].nil?
    params["protocol"] = resource[:protocol] if !resource[:protocol].nil?
    params["dst-port"] = resource[:dst_port] if !resource[:dst_port].nil?
    params["server"] = resource[:server] if !resource[:server].nil?
    params["src-address"] = resource[:src_address] if !resource[:src_address].nil?

    lookup = {}
    lookup["comment"] = resource[:name]

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/hotspot/walled-garden/ip", params, lookup)
  end
end

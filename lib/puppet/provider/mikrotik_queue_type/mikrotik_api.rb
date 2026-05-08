require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_queue_type).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    types = Puppet::Provider::Mikrotik_Api::get_all("/queue/type")
    types.each do |t|
      # Skip built-in entries that cannot be removed
      next if t['builtin'] == 'true'

      object = queueType(t)
      instances << object if object
    end

    instances
  end

  def self.queueType(data)
    new(
      :ensure                 => :present,
      :name                   => data['name'],
      :kind                   => data['kind'],
      :pcq_classifier         => data['pcq-classifier'].nil? ? nil : data['pcq-classifier'].split(','),
      :pcq_rate               => data['pcq-rate'],
      :pcq_total_limit        => data['pcq-total-limit'],
      :pcq_dst_address6_mask  => data['pcq-dst-address6-mask'],
      :pcq_src_address6_mask  => data['pcq-src-address6-mask'],
    )
  end

  def flush
    Puppet.debug("Flushing queue type #{resource[:name]}")

    params = {
      "name"                   => resource[:name],
      "kind"                   => resource[:kind],
      "pcq-classifier"         => resource[:pcq_classifier].nil? ? nil : resource[:pcq_classifier].join(','),
      "pcq-rate"               => resource[:pcq_rate],
      "pcq-total-limit"        => resource[:pcq_total_limit],
      "pcq-dst-address6-mask"  => resource[:pcq_dst_address6_mask],
      "pcq-src-address6-mask"  => resource[:pcq_src_address6_mask],
    }.compact

    lookup = { "name" => resource[:name] }

    simple_flush("/queue/type", params, lookup)
  end
end

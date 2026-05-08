require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_queue_tree).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    queues = Puppet::Provider::Mikrotik_Api::get_all("/queue/tree")
    queues.each do |q|
      object = queueTree(q)
      instances << object if object
    end

    instances
  end

  def self.queueTree(data)
    state = data['disabled'] == 'true' ? :disabled : :enabled

    new(
      :ensure      => :present,
      :state       => state,
      :name        => data['name'],
      :parent      => data['parent'],
      :packet_mark => data['packet-mark'],
      :queue       => data['queue'],
      :max_limit   => data['max-limit'],
      :limit_at    => data['limit-at'],
      :priority    => data['priority'],
      :comment     => data['comment'],
    )
  end

  def flush
    Puppet.debug("Flushing tree queue #{resource[:name]}")

    disabled = case @property_hash[:state]
               when :disabled then 'yes'
               when :enabled  then 'no'
               end

    params = {
      "name"        => resource[:name],
      "parent"      => resource[:parent],
      "packet-mark" => resource[:packet_mark],
      "queue"       => resource[:queue],
      "max-limit"   => resource[:max_limit],
      "limit-at"    => resource[:limit_at],
      "priority"    => resource[:priority],
      "comment"     => resource[:comment],
      "disabled"    => disabled,
    }.compact

    lookup = { "name" => resource[:name] }

    simple_flush("/queue/tree", params, lookup)
  end
end

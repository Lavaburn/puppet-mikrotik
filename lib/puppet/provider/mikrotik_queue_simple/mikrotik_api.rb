require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_queue_simple).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    queues = Puppet::Provider::Mikrotik_Api::get_all("/queue/simple")
    queues.each do |q|
      object = queueSimple(q)
      instances << object if object
    end

    instances
  end

  def self.queueSimple(data)
    state = data['disabled'] == 'true' ? :disabled : :enabled

    new(
      :ensure      => :present,
      :state       => state,
      :name        => data['name'],
      :target      => data['target'],
      :max_limit   => data['max-limit'],
      :limit_at    => data['limit-at'],
      :queue       => data['queue'],
      :total_queue => data['total-queue'],
      :parent      => data['parent'],
      :comment     => data['comment'],
    )
  end

  def flush
    Puppet.debug("Flushing simple queue #{resource[:name]}")

    disabled = case @property_hash[:state]
               when :disabled then 'yes'
               when :enabled  then 'no'
               end

    params = {
      "name"        => resource[:name],
      "target"      => resource[:target],
      "max-limit"   => resource[:max_limit],
      "limit-at"    => resource[:limit_at],
      "queue"       => resource[:queue],
      "total-queue" => resource[:total_queue],
      "parent"      => resource[:parent],
      "comment"     => resource[:comment],
      "disabled"    => disabled,
    }.compact

    lookup = { "name" => resource[:name] }

    simple_flush("/queue/simple", params, lookup)
  end
end

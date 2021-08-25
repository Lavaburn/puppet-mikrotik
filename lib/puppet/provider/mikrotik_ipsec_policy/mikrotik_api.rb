require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_policy).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []
    policies = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/policy")
    policies.each do |policy|
      object = ipsecPolicy(policy)
      if object != nil
        instances << object
      end
    end
    instances
  end

  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.ipsecPolicy(data)
    if data['comment'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end

      new(
        :ensure               => :present,
        :state                => state,
        :name                 => data['comment'],
        :action               => data['action'],
        :dst_address          => data['dst-address'],
        :dst_port             => data['dst-port'],
        :group                => data['group'],
        :ipsec_protocols      => data['ipsec-protocols'],
        :level                => data['level'],
        :proposal             => data['proposal'],
        :protocol             => data['protocol'],
        :src_address          => data['src-address'],
        :src_port             => data['src-port'],
        :template             => data['template'],
        :tunnel               => data['tunnel'],
        :peer                 => data['peer'],
      )
    end
  end

  def flush
    Puppet.debug("Flushing IPSec Policy #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["comment"] = resource[:name]
    params["action"] = resource[:action]
    params["dst-address"] = resource[:dst_address]
    params["dst-port"] = resource[:dst_port]
    params["group"] = resource[:group]
    params["ipsec-protocols"] = resource[:ipsec_protocols]
    params["level"] = resource[:level]
    params["proposal"] = resource[:proposal]
    params["protocol"] = resource[:protocol]
    params["src-address"] = resource[:src_address]
    params["src-port"] = resource[:src_port]
    params["template"] = resource[:template]
    params["tunnel"] = resource[:tunnel]
    params["peer"] = resource[:peer]
    params.compact!

    lookup = { "comment" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/policy", params, lookup)
  end
end

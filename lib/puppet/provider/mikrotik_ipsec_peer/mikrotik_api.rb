require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_peer).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    peers = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/peer")
    peers.each do |peer|
      object = ipsecPeer(peer)
      if object != nil
        instances << object
      end
    end

    instances
  end

  def self.ipsecPeer(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure                => :present,
      :state                 => state,
      :name                  => data['name'],
      :comment               => data['comment'],
      :address               => data['address'],
      :exchange_mode         => data['exchange-mode'],
      :local_address         => data['local-address'],
      :passive               => data['passive'],
      :port                  => data['port'],
      :profile               => data['profile'],
      :send_initial_contact  => data['send-initial-contact'],
    )
  end

  def flush
    Puppet.debug("Flushing IPSec Peer #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["name"] = resource[:name]
    params["comment"] = resource[:comment]
    params["address"] = resource[:address]
    params["exchange-mode"] = resource[:exchange_mode]
    params["local-address"] = resource[:local_address]
    params['passive'] = resource[:passive]
    params['port'] = resource[:port]
    params['send-initial-contact'] = resource[:send_initial_contact]
    params['profile'] = resource[:profile]
    params.compact!

    lookup = { "name" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/peer", params, lookup)
  end
end

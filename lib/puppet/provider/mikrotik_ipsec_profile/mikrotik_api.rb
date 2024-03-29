require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_profile).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    profiles = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/profile")
    profiles.each do |profile|
      object = ipsecProfile(profile)
      if object != nil
        instances << object
      end
    end

    instances
  end

  def self.ipsecProfile(data)
    new(
      :ensure                => :present,
      :name                  => data['name'],
      :dh_group              => data['dh-group'].nil? ? nil : data['dh-group'].split(','),
      :dpd_interval          => data['dpd-interval'],
      :dpd_maximum_failures  => data['dpd-maximum-failures'],
      :enc_algorithm         => data['enc-algorithm'].nil? ? nil : data['enc-algorithm'].split(','),
      :hash_algorithm        => data['hash-algorithm'],
      :lifebytes             => data['lifebytes'],
      :lifetime              => data['lifetime'],
      :nat_traversal         => data['nat-traversal'],
      :prf_algorithm         => data['prf-algorithm'] || 'auto',
      :proposal_check        => data['proposal-check'],
    )
  end

  def flush
    Puppet.debug("Flushing IPSec Profile #{resource[:name]}")

    params = {}

    params["name"] = resource[:name]
    params["dh-group"] = resource[:dh_group].join(',') unless resource[:dh_group].nil?
    params["dpd-interval"] = resource[:dpd_interval]
    params["dpd-maximum-failures"] = resource[:dpd_maximum_failures]
    params["enc-algorithm"] = resource[:enc_algorithm].join(',') unless resource[:enc_algorithm].nil?
    params["hash-algorithm"] = resource[:hash_algorithm]
    params["lifebytes"] = resource[:lifebytes]
    params["lifetime"] = resource[:lifetime]
    params['nat-traversal'] = resource[:nat_traversal]
    params['prf-algorithm'] = resource[:prf_algorithm]
    params['proposal-check'] = resource[:proposal_check]
    params.compact!

    lookup = { "name" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/profile", params, lookup)
  end
end

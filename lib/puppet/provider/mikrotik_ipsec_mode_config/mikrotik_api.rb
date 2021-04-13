require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_mode_config).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    modes = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/mode-config")
    modes.each do |mode|
      object = ipsecModeConfig(mode)
      if object != nil
        instances << object
      end
    end

    instances
  end

  def self.ipsecModeConfig(data)
    new(
      :ensure                => :present,
      :name                  => data['name'],
      :comment               => data['comment'],
      :address_pool          => data['address-pool'],
      :address_prefix_length => data['address-prefix-length'],
      :split_include         => data['split-include'].nil? ? nil : data['split-include'].split(','),
      :static_dns            => data['static-dns'].nil? ? nil : data['static_dns'].split(','),
      :system_dns            => data['system-dns'],
    )
  end

  def flush
    Puppet.debug("Flushing IPSec Mode Config #{resource[:name]}")

    params = {
      "name"                  => resource[:name],
      "comment"               => resource[:comment],
      "address-pool"          => resource[:address_pool],
      "address-prefix-length" => resource[:address_prefix_length],
      "split-include"         => resource[:split_include].nil? ? nil : resource[:split_include].join(','),
      "static-dns"            => resource[:static_dns].nil? ? nil : resource[:static_dns].join(','),
      "system-dns"            => resource[:system_dns],
    }.compact

    lookup = { "name" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/mode-config", params, lookup)
  end
end

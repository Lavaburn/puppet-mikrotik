require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_identity).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik

  mk_resource_methods

  def self.instances
    instances = []

    identities = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/identity")
    identities.each do |identity|
      object = ipsecIdentity(identity)
      if object != nil
        instances << object
      end
    end

    instances
  end

  def self.ipsecIdentity(data)
    if data['comment'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end

      eap_methods = data['eap-methods'].split(',').map {|mthd| mthd[4..-1] }

      new(
        :ensure                => :present,
        :state                 => state,
        :name                  => data['comment'],
        :auth_method           => data['auth-method'],
        :certificate           => data['certificate'],
        :eap_methods           => eap_methods,
        :generate_policy       => data['generate-policy'],
        :key                   => data['key'],
        :match_by              => data['match-by'],
        :mode_config           => data['mode-config'],
        :my_id                 => data['my-id'],
        :notrack_chain         => data['notrack-chain'],
        :password              => data['password'],
        :policy_template_group => data['policy-template-group'],
        :remote_certificate    => data['remote-certificate'],
        :remote_id             => data['remote-id'],
        :remote_key            => data['remote-key'],
        :secret                => data['secret'],
        :peer                  => data['peer'],
      )
    end
  end

  def flush
    Puppet.debug("Flushing IPSec Identity #{resource[:name]}")

    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end

    params["comment"] = resource[:name]
    params["auth-method"] = resource[:auth_method]
    params["certificate"] = resource[:certificate]
    params["eap-methods"] = resource[:eap_methods].map {|mthd| "eap-#{mthd}" }.join(',') unless resource[:eap_methods].nil?
    params["generate-policy"] = resource[:generate_policy]
    params['key'] = resource[:key]
    params['match-by'] = resource[:match_by]
    params["mode-config"] = resource[:mode_config]
    params["my-id"] = resource[:my_id]
    params['notrack-chain'] = resource[:notrack_chain]
    params['password'] = resource[:password]
    params['policy-template-group'] = resource[:policy_template_group]
    params['remote-certificate'] = resource[:remote_certificate]
    params['remote-id'] = resource[:remote_id]
    params['remote-key'] = resource[:remote_key]
    params['secret'] = resource[:secret]
    params['username'] = resource[:username]
    params['peer'] = resource[:peer]
    params.compact!

    lookup = { "comment" => resource[:name] }

    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/identity", params, lookup)
  end
end

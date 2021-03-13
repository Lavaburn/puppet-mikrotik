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
    if data['comment'] != nil
      if data['disabled'] == "true"
        state = :disabled
      else
        state = :enabled
      end
      
      new(
        :ensure                => :present,
        :state                 => state,
        :name                  => data['comment'],
        :address               => data['address'],
        :auth_method           => data['auth-method'],
        :certificate           => data['certificate'],
        :compatibility_options => data['compatibility-options'],
        :dh_group              => data['dh-group'].nil? ? nil : data['dh-group'].split(','),
        :dpd_interval          => data['dpd-interval'],
        :dpd_maximum_failures  => data['dpd-maximum-failures'],
        :enc_algorithm         => data['enc-algorithm'].nil? ? nil : data['enc-algorithm'].split(','),
        :exchange_mode         => data['exchange-mode'],
        :generate_policy       => data['generate-policy'],
        :hash_algorithm        => data['hash-algorithm'],
        :key                   => data['key'],
        :lifebytes             => data['lifebytes'],
        :lifetime              => data['lifetime'],
        :local_address         => data['local-address'],
        :mode_config           => data['mode-config'],
        :my_id                 => data['my-id'],
        :nat_traversal         => data['nat-traversal'],
        :notrack_chain         => data['notrack-chain'],
        :passive               => data['passive'],
        :policy_template_group => data['policy-template-group'],
        :port                  => data['port'],
        :proposal_check        => data['proposal_check'],
        :remote_certificate    => data['remote-certificate'],
        :remote_key            => data['remote-key'],
        :secret                => data['secret'],
        :send_initial_contact  => data['send-initial-contact'],
        :xauth_login           => data['xauth-login'],
        :xauth_password        => data['xauth-password'],
      )
    end
  end

  def flush
    Puppet.debug("Flushing IPSec Peer #{resource[:name]}")
      
    params = {}

    if @property_hash[:state] == :disabled
      params["disabled"] = 'yes'
    elsif @property_hash[:state] == :enabled
      params["disabled"] = 'no'
    end
    
    params["comment"] = resource[:name]
    params["address"] = resource[:address]
    params["auth-method"] = resource[:auth_method]
    params["certificate"] = resource[:certificate]
    params["compatibility-options"] = resource[:compatibility_options]
    params["dh-group"] = resource[:dh_group].join(',') unless resource[:dh_group].nil?
    params["dpd-interval"] = resource[:dpd_interval]
    params["dpd-maximum-failures"] = resource[:dpd_maximum_failures]
    params["enc-algorithm"] = resource[:enc_algorithm].join(',') unless resource[:enc_algorithm].nil?
    params["exchange-mode"] = resource[:exchange_mode]
    params["generate-policy"] = resource[:generate_policy]
    params["hash-algorithm"] = resource[:hash_algorithm]
    params['key'] = resource[:key]
    params["lifebytes"] = resource[:lifebytes]
    params["lifetime"] = resource[:lifetime]
    params["local-address"] = resource[:local_address]
    params["mode-config"] = resource[:mode_config]
    params["my-id"] = resource[:my_id]
    params['nat-traversal'] = resource[:nat_traversal]
    params['notrack-chain'] = resource[:notrack_chain]
    params['passive'] = resource[:passive]
    params['policy-template-group'] = resource[:policy_template_group]
    params['port'] = resource[:port]
    params['proposal-check'] = resource[:proposal_check]
    params['remote-certificate'] = resource[:remote_certificate]
    params['remote-key'] = resource[:remote_key]
    params['secret'] = resource[:secret]
    params['send-initial-contact'] = resource[:send_initial_contact]
    params['xauth-login'] = resource[:xauth_login]
    params['xauth-password'] = resource[:xauth_password]
    params.compact!

    lookup = { "comment" => resource[:name] }
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/peer", params, lookup)
  end  
end

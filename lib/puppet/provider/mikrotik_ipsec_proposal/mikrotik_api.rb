require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_ipsec_proposal).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    proposals = Puppet::Provider::Mikrotik_Api::get_all("/ip/ipsec/proposal")
    proposals.each do |proposal|
      object = ipsecProposal(proposal)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.ipsecProposal(data)
    if data['disabled'] == "true"
      state = :disabled
    else
      state = :enabled
    end

    new(
      :ensure          => :present,
      :state           => state,
      :name            => data['name'],
      :comment         => data['comment'],
      :auth_algorithms => data['auth-algorithms'].nil? ? nil : data['auth-algorithms'].split(','),
      :enc_algorithms  => data['enc-algorithms'].nil? ? nil : data['enc-algorithms'].split(','),
      :lifetime        => data['lifetime'],
      :pfs_group       => data['pfs-group'],
    )
  end

  def flush
    Puppet.debug("Flushing IPSec Proposal #{resource[:name]}")

    if @property_hash[:state] == :disabled
      disabled = 'yes'
    elsif @property_hash[:state] == :enabled
      disabled = 'no'
    end
      
    params = {
      "name"                  => resource[:name],
      "comment"               => resource[:comment],
      "disabled"              => disabled,
      "auth-algorithms"       => resource[:auth_algorithms].nil? ? nil : resource[:auth_algorithms].join(','),
      "enc-algorithms"        => resource[:enc_algorithms].nil? ? nil : resource[:enc_algorithms].join(','),
      "lifetime"              => resource[:lifetime],
      "pfs-group"             => resource[:pfs_group],
    }.compact

    lookup = { "name" => resource[:name] }
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/ipsec/proposal", params, lookup)
  end  
end

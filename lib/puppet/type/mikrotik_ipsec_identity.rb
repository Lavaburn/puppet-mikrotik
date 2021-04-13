require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_identity) do
  apply_to_all

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:enabled) do
      provider.setState(:enabled)
    end

    newvalue(:disabled) do
      provider.setState(:disabled)
    end

    def retrieve
      provider.getState
    end

    def insync?(is)
      @should.each { |should|
        case should
          when :present
            return (provider.getState != :absent)
          when :absent
            return (provider.getState == :absent)
          when :enabled
            return (provider.getState == :enabled)
          when :disabled
            return (provider.getState == :disabled)
        end
      }
    end
  end

  newparam(:name) do
    desc 'The unique identifier for this identity'
    isnamevar
  end

  newproperty(:auth_method) do
    desc 'The authentication method to use.'
    newvalues(*%w{digital-signature eap eap-radius pre-shared-key pre-shared-key-xauth rsa-key rsa-signature-hybrid})
  end

  newproperty(:certificate) do
    desc 'Name of an installed certificate to use for signing packets.'
  end

  newproperty(:eap_methods, :array_matching => :all) do
    newvalues(:mschapv2, :peap, :tls, :ttls)
  end

  newproperty(:generate_policy) do
    desc 'Whether this identity is allowed to dynamically generate a policy from a policy-template-group if no existing policy matches'
    newvalues(*%w{no port-override port-strict})
  end

  newproperty(:key) do
    desc 'name of the private key to use from the installed IPSec Keys. Only applicable if auth_method is rsa-key.'
  end

  newproperty(:match_by) do
    newvalues(:certificate, :remote_id)
  end

  newproperty(:mode_config) do
  end

  newproperty(:my_id) do
  end

  newproperty(:notrack_chain) do
  end

  newproperty(:password) do
  end

  newproperty(:peer) do
  end

  newproperty(:policy_template_group) do
  end

  newproperty(:remote_certificate) do
  end

  newproperty(:remote_id) do
  end

  newproperty(:remote_key) do
  end

  newproperty(:secret) do
  end

  newproperty(:username) do
  end

  autorequire(:mikrotik_certificate) { self[:certificate] }
  autorequire(:mikrotik_ipsec_mode_config) { self[:mode_config] }
  autorequire(:mikrotik_ipsec_peer) { self[:peer] }
  autorequire(:mikrotik_ipsec_group) { self[:policy_tempalte_group] }
end

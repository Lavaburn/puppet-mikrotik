require 'puppet/property/boolean'

Puppet::Type.newtype(:mikrotik_ipsec_policy) do
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
    desc 'Policy description'
    isnamevar
  end

  newproperty(:src_address) do
    desc 'Source Address'
  end

  newproperty(:src_port) do
    desc 'Source port'
  end

  newproperty(:dst_address) do
    desc 'Destination Address'
  end

  newproperty(:dst_port) do
    desc 'Destination Port'
  end

  newproperty(:protocol) do
    desc "The protocol to something something"
    newvalues(*%w{
      all dccp ddp egp encap etherip ggp gre hmp icmp icmpv6 idpr-cmtp igmp ipencap ipip ipsec-ah ipsec-esp ipv6 ipv6-frag ipv6-nonxt
      ipv6-opts ipv6-route iso-tp4 l2tp ospf pim pup rdp rspf rsvp sctp st tcp udp udp-lite vmtp vrrp xns-idp xtp
    })
  end

  newproperty(:template, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'whether to template???'
    defaultto true
  end

  newproperty(:group) do
  end

  newproperty(:action) do
    desc 'The action to take'
    newvalues(:encrypt,:discard,:none)
  end

  newproperty(:ipsec_protocols) do
    newvalues(:esp,:ah)
  end

  newproperty(:sa_src_address) do
  end

  newproperty(:sa_dst_address) do
  end

  newproperty(:proposal) do
  end

  newproperty(:level) do
    newvalues(:require,:unique,:use)
  end

  newproperty(:tunnel, boolean: true, parent: Puppet::Property::Boolean) do
  end
end

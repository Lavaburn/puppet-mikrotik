Puppet::Type.newtype(:mikrotik_interface_vlan) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  #TODO disabled -- Defines whether item is ignored or used

  newparam(:name) do
    desc 'The name of the VLAN (802.1q) interface'
    isnamevar
  end

  newproperty(:mtu) do
    desc 'Maximum Transmit Unit'
  end

  newproperty(:arp) do
    desc 'Address Resolution Protocol to use'
    newvalues('enabled', 'disabled', 'proxy-arp', 'reply-only')
  end

  newproperty(:arp_timeout) do
    desc 'Address Resolution Protocol Timeout'
  end
  
  newproperty(:vlan_id) do
    desc 'VLAN tag that is used to distinguish VLANs'
  end

  newproperty(:interface) do
    desc 'Physical interface to the network where are VLANs'
  end

  newproperty(:use_service_tag) do
    desc 'Whether to use VLAN Service Tag'
    newvalues(false, true)
    defaultto true
  end
end

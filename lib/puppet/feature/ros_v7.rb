require 'puppet/util/feature'
require_relative '../util/network_device/mikrotik/facts'
require_relative '../util/network_device/transport/mikrotik'

Puppet.features.add(:ros_v7) do
  begin
    transport = nil
    if Puppet::Util::NetworkDevice.current
      #we are in `puppet device`
      transport = Puppet::Util::NetworkDevice.current.transport
    else
      #we are in `puppet resource`
      transport = Puppet::Util::NetworkDevice::Transport::Mikrotik.new(Facter.value(:url))
    end

    facts = Puppet::Util::NetworkDevice::Mikrotik::Facts.new(transport).retrieve
    Puppet.debug("ROSv7: #{facts['version']}")
    if facts and facts['version'] =~ /^7\./
      true
    else
      false
    end
  rescue
    false
  end
end
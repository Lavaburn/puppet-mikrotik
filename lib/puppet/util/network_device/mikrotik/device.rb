require 'puppet/util/network_device'
require 'puppet/util/network_device/mikrotik/facts'
require 'puppet/util/network_device/transport/mikrotik'

class Puppet::Util::NetworkDevice::Mikrotik::Device
  attr_reader :connection
  attr_accessor :url, :transport

  def initialize(url, options = {})
    @autoloader = Puppet::Util::Autoload.new(
      self,
      'puppet/util/network_device/transport'
    )
    if @autoloader.load('mikrotik')
      @transport = Puppet::Util::NetworkDevice::Transport::Mikrotik.new(url, options[:debug])
    end
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Mikrotik::Facts.new(@transport)

    @facts.retrieve
  end
end
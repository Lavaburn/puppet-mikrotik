require 'puppet/util/network_device'
require_relative 'facts'
require_relative '../transport/mikrotik'

class Puppet::Util::NetworkDevice::Mikrotik::Device
  attr_reader :connection
  attr_accessor :url, :transport

  def initialize(url, options = {})
    # Puppet 5 support
    if Gem::Version.new(Puppet.version) < Gem::Version.new("6.0.0")      
      @autoloader = Puppet::Util::Autoload.new(self, 'puppet/util/network_device/transport')
      @autoloader.load('mikrotik')
    end
 
    @transport = Puppet::Util::NetworkDevice::Transport::Mikrotik.new(url, options[:debug])
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Mikrotik::Facts.new(@transport)

    @facts.retrieve
  end
end
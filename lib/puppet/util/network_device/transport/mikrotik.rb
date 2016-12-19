require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

class Puppet::Util::NetworkDevice::Transport::Mikrotik < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'uri'
    require 'mtik'
    
    url_object = URI(url)
    
    # TODO SSH Provider ? => url_object.scheme
    # TODO  #{url_object.username} #{url_object.password} = NULL !!!
    @connection = MTik::Connection.new :host => url_object.host, :user => 'admin', :pass => 'wimaxrouter', :conn_timeout => 10
  end
end
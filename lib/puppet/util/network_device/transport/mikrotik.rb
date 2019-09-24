require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

require 'mtik' if Puppet.features.mtik?

class Puppet::Util::NetworkDevice::Transport::Mikrotik < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'uri'
    
    url_object = URI(url)

    if (url_object.scheme == 'api')
      @connection = MTik::Connection.new :host => url_object.host, :user => url_object.user, :pass => url_object.password, :unecrypted_plaintext => true, :conn_timeout => 10
    else 
      raise "The Mikrotik module currently only support API access. Use api:// in URL."  
    end    
  end
end
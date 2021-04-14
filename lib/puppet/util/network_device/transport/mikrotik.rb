require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

require 'mtik' if Puppet.features.mtik?

class Puppet::Util::NetworkDevice::Transport::Mikrotik < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'uri'

    url_object = URI(url)

    case url_object.scheme
    when 'api'
      @connection = MTik::Connection.new :host => url_object.host, :user => url_object.user, :pass => url_object.password, :unencrypted_plaintext => true, :conn_timeout => 10
    when 'file'
      config = JSON.parse(File.read(url_object.path))

      raise "When using an advanced config file, the 'host' option is required" unless config['host']

      opts = {
        host: config['host'],
        user: config['user'],
        pass: config['password'],
        conn_timeout: 10,
        use_ssl: config['use_ssl'],
      }.compact!

      opts[:port] = config['port'].to_i if config['port']
      opts[:conn_timeout] = config['conn_timeout'].to_i if config['conn_timeout']
      opts[:cmd_timeout] = config['cmd_timeout'].to_i if config['cmd_timeout']
      opts[:unencrypted_plaintext] = config.has_key?('unencrypted_plaintext') ? config['unencrypted_plaintext'] : !config['use_ssl']

      @connection = MTik::Connection.new(opts)
      @include_ec2_facts = config['include_ec2_facts']
    else
      raise "The Mikrotik module currently only support API access. Use either api:// in URL, or use file:// for advanced config from a separate JSON file."
    end
  end

  def include_ec2_facts?
    !!@include_ec2_facts
  end
end
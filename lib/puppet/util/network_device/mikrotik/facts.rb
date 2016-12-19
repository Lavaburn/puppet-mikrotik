require 'puppet/util/network_device/mikrotik'

class Puppet::Util::NetworkDevice::Mikrotik::Facts
  attr_reader :transport
  
  def initialize(transport)
    @transport = transport
  end

  def connection
    @transport.connection
  end

  def retrieve
    facts = {}
    
    system_resources = connection.get_reply("/system/resource/getall")    
    system_resources.each do |system_resource| 
      if system_resource.key?('!re')
        facts = system_resource.reject { |k, v| ['!re', '.tag'].include? k }
      end
    end
    
    facts
  end
end
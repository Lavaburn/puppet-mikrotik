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
    facts_raw = {}    
    system_resources = connection.get_reply("/system/resource/getall")    
    system_resources.each do |system_resource| 
      if system_resource.key?('!re')
        facts_raw = system_resource.reject { |k, v| ['!re', '.tag'].include? k }
      end
    end
    
    facts = {}
    facts_raw.each do |k, v|
      new_key = k.gsub(/-/, '_')
      facts[new_key] = v
    end
    
    facts
  end
end
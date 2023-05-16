require_relative '../mikrotik_api'

Puppet::Type.type(:mikrotik_tool_email).provide(:mikrotik_api_v6, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  confine :feature => :ros_v6
  
  mk_resource_methods

  def self.instances
    instances = []
      
    email = Puppet::Provider::Mikrotik_Api::get_all("/tool/e-mail")
    email.each do |data|
      object = toolEmail(data)
      if object != nil
        instances << object
      end
    end

    instances
  end
  
  def self.toolEmail(data)
    new(
      :name            => 'email',
      :server          => data['address'],
      :port            => data['port'],
      :username        => data['user'],
      :password        => data['password'],
      :from_address    => data['from'],
      :enable_starttls => convertYesNoToBool(data['start-tls']).to_s
    )
  end

  def flush
    Puppet.debug("Flushing Tool E-mail")
    
    if (@property_hash[:name] != 'email') 
      raise "There is only one set of E-Mail Tool settings. Title (name) should be -email-"
    end
    
    update = {}
    update["address"] = resource[:server] if ! resource[:server].nil?
    update["port"] = resource[:port] if ! resource[:port].nil?
    update["user"] = resource[:username] if ! resource[:username].nil?
    update["password"] = resource[:password] if ! resource[:password].nil?
    update["from"] = resource[:from_address] if ! resource[:from_address].nil?
    update["start-tls"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:enable_starttls]) if ! resource[:enable_starttls].nil?
    
    result = Puppet::Provider::Mikrotik_Api::set("/tool/e-mail", update)
  end
end
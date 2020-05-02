require 'puppet/provider/mikrotik_api'

Puppet::Type.type(:mikrotik_ip_hotspot_profile).provide(:mikrotik_api, :parent => Puppet::Provider::Mikrotik_Api) do
  confine :feature => :mtik
  
  mk_resource_methods

  def self.instances   
    instances = []
      
    profiles = Puppet::Provider::Mikrotik_Api::get_all("/ip/hotspot/profile")
    profiles.each do |profile|
      object = hsProfile(profile)
      if object != nil        
        instances << object
      end
    end
    
    instances
  end
  
  def self.hsProfile(data)
    new(
      :ensure                => :present,
      :name                  => data['name'],
      :dns_name              => data['dns-name'],
      :hotspot_address       => data['hotspot-address'],
      :html_directory        => data['html-directory'],
      # html-directory-override
      :http_cookie_lifetime  => data['http-cookie-lifetime'],
      #  http-proxy
      :login_by              => data['login-by'].split(','),
      # mac-auth-mode
      # mac-auth-password
      :nas_port_type         => data['nas-port-type'],
      :radius_accounting     => (data['radius-accounting'].nil? ? :false : data['radius-accounting']),
      :radius_default_domain => data['radius-default-domain'],
      :radius_interim_update => data['radius-interim-update'],
      :radius_location_id    => data['radius-location-id'],
      :radius_location_name  => data['radius-location-name'],
      # radius-mac-format
      # rate-limit
      # smtp-server
      :split_user_domain     => (data['split-user-domain'].nil? ? :false : data['split-user-domain']),
      #ssl-certificate
      :trial_uptime_limit    => data['trial-uptime-limit'],
      :trial_uptime_reset    => data['trial-uptime-reset'],
      :trial_user_profile    => data['trial-user-profile'],
      :use_radius            => (data['use-radius'].nil? ? :false : data['use-radius'])
    )
  end

  def flush
    Puppet.debug("Flushing Hotspot Profile #{resource[:name]}")
      
    params = {}

    params["name"] = resource[:name]
    params["dns-name"] = resource[:dns_name] if !resource[:dns_name].nil?
    params["hotspot-address"] = resource[:hotspot_address] if !resource[:hotspot_address].nil?
    params["html-directory"] = resource[:html_directory] if !resource[:html_directory].nil?
    params["http-cookie-lifetime"] = resource[:http_cookie_lifetime] if !resource[:http_cookie_lifetime].nil?
    params["nas-port-type"] = resource[:nas_port_type] if !resource[:nas_port_type].nil?
    params["radius-default-domain"] = resource[:radius_default_domain] if !resource[:radius_default_domain].nil?
    params["radius-interim-update"] = resource[:radius_interim_update] if !resource[:radius_interim_update].nil?
    params["radius-location-id"] = resource[:radius_location_id] if !resource[:radius_location_id].nil?
    params["radius-location-name"] = resource[:radius_location_name] if !resource[:radius_location_name].nil?
    params["trial_uptime_limit"] = resource[:trial_uptime_limit] if !resource[:trial_uptime_limit].nil?
    params["trial_uptime_reset"] = resource[:trial_uptime_reset] if !resource[:trial_uptime_reset].nil?
    params["trial_user_profile"] = resource[:trial_user_profile] if !resource[:trial_user_profile].nil?

    params["login-by"] = resource[:login_by].join(',') if ! resource[:login_by].nil?
    
    params["radius-accounting"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:radius_accounting]) if ! resource[:radius_accounting].nil?
    params["split-user-domain"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:split_user_domain]) if ! resource[:split_user_domain].nil?
    params["use-radius"] = Puppet::Provider::Mikrotik_Api::convertBoolToYesNo(resource[:use_radius]) if ! resource[:use_radius].nil?

    lookup = {}
    lookup["name"] = resource[:name]
    
    Puppet.debug("Params: #{params.inspect} - Lookup: #{lookup.inspect}")

    simple_flush("/ip/hotspot/profile", params, lookup)
  end  
end

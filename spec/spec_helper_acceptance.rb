require 'beaker-rspec'

require 'support/faulty_device_run'
require 'support/idempotent_device_run'
require 'support/idempotent_manifest'
require 'support/testnodes'

RSpec.configure do |c|
  c.before :suite do
    # Test Nodes
    @testnodes = get_testnodes
    
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    
    # Generic for every host    
    hosts.each do |host|
      # Install this module
      install_dev_puppet_module_on(host, :source => proj_root, :module_name => 'mikrotik', :target_module_path => '/etc/puppetlabs/code/environments/production/modules')
    end

    # On master
    unless ENV['BEAKER_provision'] == 'no'
      on master, 'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys --recv-keys 7F438280EF8D349F'
      on master, 'apt-get update'
      on master, 'apt-get install -y puppetserver'
      on master, 'cp /etc/default/puppetserver /tmp/puppetserver'
      on master, 'sed -e "s/2g/1g/g" /tmp/puppetserver > /etc/default/puppetserver'
      
      autosign_conf = ""
      autosign_file = '/etc/puppetlabs/puppet/autosign.conf'
      @testnodes.each { |node| autosign_conf << "#{node[:name]}\n" }
      
      create_remote_file(master, autosign_file, autosign_conf)
      on master, "chown puppet #{autosign_file}"
      
      on master, 'service puppetserver start'
    end
  
    # Agents
    agents.each do |agent|        
      # Set device.conf
      device_conf = ""
      @testnodes.each { |node| device_conf << "[#{node[:name]}]\n  type mikrotik\n  url api://admin:wimaxrouter@#{node[:ip]}\n" }
        
      create_remote_file(agent, '/etc/puppetlabs/puppet/device.conf', device_conf)
    end
  end
end

def run_puppet_device_on(devices) 
  if ENV['BEAKER_debug']
    debug="--debug"
  else
    debug="--verbose"
  end
  
  devices.each do |device| 
    @result = on(device, "puppet device --detailed-exitcodes #{debug}", :accept_all_exit_codes => true)
  end
  
  @result
end

def apply_manifests(devices, manifest) 
  devices.each do |device| 
    @result = apply_manifest_on(device, manifest, :accept_all_exit_codes => true)
  end
  
  @result
end  

def set_site_pp_on_master(nodes_config)
  site_pp = '/etc/puppetlabs/code/environments/production/manifests/site.pp'
  
  create_remote_file(master, site_pp, create_site_pp(nodes_config))
  on master, "chown puppet #{site_pp}"
end

def create_site_pp(site_pp)
  result = ""
  @testnodes.each { |node| result << "node '#{node[:name]}' {\n#{site_pp}\n}\n" }
  
  result
end

def get_testnodes
   [
     { 
       :name => 'dude1.rcswimax.com',
       :ip   => '105.235.209.44',
     }
   ] 
 end

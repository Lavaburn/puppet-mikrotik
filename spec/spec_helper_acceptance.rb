require 'puppet'

require 'beaker-rspec'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

require 'beaker-puppet'

require 'beaker'
require 'beaker/puppet_install_helper'

require 'support/changing_device_run'
require 'support/empty_device_run'
require 'support/faulty_device_run'
require 'support/idempotent_device_run'
require 'support/idempotent_device_run_after_failures'
require 'support/idempotent_manifest'
require 'support/testnodes'

RSpec.configure do |c|
  c.before :suite do
    # Test Nodes
    @testnodes = get_testnodes
    
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      
    # Install the correct Puppet version
    #run_puppet_install_helper("agent", "5.5.10")
    run_puppet_install_helper("agent", "6.13.0")
      
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
      # TODO ? agents.each { |agent| autosign_conf << "#{agent[:name]}\n" }
      autosign_file = '/etc/puppetlabs/puppet/autosign.conf'
      @testnodes.each { |node| autosign_conf << "#{node[:name]}\n" }
      
      create_remote_file(master, autosign_file, autosign_conf)
      on master, "chown puppet #{autosign_file}"
      
      on master, 'service puppetserver start'  
        
      # TODO: The strangest BUGFIX for Puppetserver 6.15.1
      on master, 'mkdir -p /opt/puppetlabs/server/data/puppetserver/yaml/facts'
      on master, 'chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/yaml'
        
      # TODO ? # Pluginsync requires 1 run on master?
      # TODO ? site_pp = '/etc/puppetlabs/code/environments/production/manifests/site.pp'
      # TODO ? create_remote_file(master, site_pp, 'node default {}')
      # TODO ? on master, "chown puppet #{site_pp}"
      # TODO ? on master, "puppet agent -t"
  
      # First time, install mtik gem on all hosts
      hosts.each do |host|
        # on host, '/opt/puppetlabs/puppet/bin/gem install mtik'
        apply_manifest_on(host, "include ::mikrotik")
      end
    end
  
    # Agents
    agents.each do |agent|      
      # TODO ? # Pluginsync requires 1 run on agent?
      # TODO ? on master, "puppet agent -t"
        
      # Set device.conf
      device_conf = ""
      @testnodes.each { |node| device_conf << "[#{node[:name]}]\n  type mikrotik\n  url api://#{node[:username]}:#{node[:password]}@#{node[:ip]}\n" }

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
    @result = on(device, "/opt/puppetlabs/puppet/bin/puppet device --detailed-exitcodes #{debug}", :accept_all_exit_codes => true)
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
  @testnodes.each { |node| result << "node default {\n\n}\n\nnode '#{node[:name]}' {\n#{site_pp}\n}\n" }
  
  result
end

def get_testnodes
  yaml = YAML.load_file("spec/fixtures/testnodes.yaml")
  nodes = yaml["testnodes"].values.collect { |node|
    {
      :name     => node["name"],
      :ip       => node["ip"],
      :username => node["username"],
      :password => node["password"],    
    }
  }
  nodes
end

def get_upgrade_source
  yaml = YAML.load_file("spec/fixtures/upgrade_source.yaml")

  {
    :hostname => yaml["hostname"],
    :username => yaml["username"],
    :password => yaml["password"],
    :version1 => yaml["version1"],
    :version2 => yaml["version2"],
  }
end

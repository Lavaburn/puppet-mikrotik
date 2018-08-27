# puppet-mikrotik
Puppet Module for managing Mikrotik Devices

Work in Progress.

### Bootstrap
For local testing using RVM:
* rvm use 2.1.8
* gem install bundler -v 1.10.6			# Compatible with Vagrant 1.8.1
* bundle install --binstubs
* rake beaker

### Defining SUT and environment
* See spec/fixtures/testnodes.example.yaml
* See spec/fixtures/upgrade_source.example.yaml

### Optional: using CHR as testmachine
* vagrant boxes add dulin/mikrotik
* cd vagrant; vagrant up
See spec/fixtures/testnodes.example.yaml

### Tested Using
* Ruby 2.1.8
* Puppet 4.3.2
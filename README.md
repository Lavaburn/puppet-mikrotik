# puppet-mikrotik
Puppet Module for managing Mikrotik Devices

Work in Progress.

### Bootstrap
For local testing using RVM:
* rvm use 2.4.5
* gem install bundler
* bundle install --binstubs [LEGACY?]
* rake beaker

### Defining SUT and environment
* See spec/fixtures/testnodes.example.yaml
* See spec/fixtures/upgrade_source.example.yaml

### Optional: using CHR as testmachine
* vagrant boxes add dulin/mikrotik
* cd vagrant; vagrant up
See spec/fixtures/testnodes.example.yaml

### Tested Using
Works:
* Ruby 2.1.8
* Puppet 4.3.2

Works: 
* Ruby 2.4.5
* Puppet 5.5.10

DOES NOT WORK: 
* Ruby 2.4.5
* Puppet 6.0.5 - 6.2.0

## Support
* ONLY Puppet 4 and 5 supported!

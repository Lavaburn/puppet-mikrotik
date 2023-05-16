# puppet-mikrotik

Puppet Module for managing Mikrotik Devices

## Testing

### Bootstrap

For local testing using RVM:
	
	rvm use 2.4.9
	gem install bundler
	bundle install --binstubs

### Acceptance Testing

Single run:

	rake beaker
	
Multiple runs: 
	
	BEAKER_provision=yes BEAKER_destroy=no rake beaker
	
	BEAKER_provision=no BEAKER_destroy=no rake beaker
	
	BEAKER_provision=no BEAKER_destroy=onpass rake beaker
	
#### Debugging inside Vagrant

	cd .vagrant/beaker_vagrant_files/beaker_default.yml
	
	vagrant ssh puppet
	vagrant ssh ubuntu-16-04

#### Defining SUT and environment

* See spec/fixtures/testnodes.example.yaml
* See spec/fixtures/upgrade_source.example.yaml

#### Optional: using CHR as testmachine

* vagrant boxes add dulin/mikrotik
* cd vagrant; vagrant up
See spec/fixtures/testnodes.example.yaml

## NOTES

### IPv6

The IPv6 package is not installed by default on ROSv6. The relevant acceptance tests have a section to install the package (optional).

### Tested Using

Works:
* Ruby 2.1.8
* Puppet 4.3.2

Works: 
* Ruby 2.4.5
* Puppet 5.5.10

Works (since "puppet6" branch): 
* Ruby 2.4.5
* Puppet 6.13.0

### Supported RouterOS versions for acceptance testing

Idempotency is not guaranteed for any other RouterOS versions. Your mileage may vary...

TESTED against v6.49.7
TESTED against v7.6

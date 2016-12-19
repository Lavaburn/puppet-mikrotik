source "https://rubygems.org"

group :test do
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 4.3.2'  
  gem 'puppetlabs_spec_helper'
end

group :acceptance do
  # Version Pinned to support Ruby 2.1.8
  gem 'beaker', '~> 2.52.0'
  gem 'beaker-rspec', '~> 5.6.0'
    
  # Bug (?) - should be included by beaker-rspec
  gem 'serverspec'
  gem 'vagrant-wrapper'

  gem 'beaker-puppet_install_helper'
end

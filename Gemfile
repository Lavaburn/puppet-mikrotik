source "https://rubygems.org"

group :test do
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 6.2.0'  
  gem 'puppetlabs_spec_helper', '~> 2.13.1'
end

group :acceptance do
  # Ruby 2.4.5
  gem 'beaker', '~> 4.5.0'
  gem 'beaker-puppet', '~> 1.16.0'
  gem 'beaker-puppet_install_helper', '~> 0.9.7'    
  gem 'beaker-rspec', '~> 6.2.4'
  gem 'beaker-vagrant', '~> 0.6.2'
  gem 'vagrant-wrapper', '~> 2.0.3'  
end

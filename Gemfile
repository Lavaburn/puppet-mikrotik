source "https://rubygems.org"

group :test do
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 6.2.0'  
  gem 'puppetlabs_spec_helper', '~> 2.13.1'
  # No Lockfile added to repo...
  gem 'mutex_m', '~> 0.1.2'
  gem 'semantic_puppet', '~> 1.0.4'
end

group :acceptance do
  # Ruby 2.4.5
  gem 'beaker', '~> 4.5.0'
  gem 'beaker-puppet', '~> 1.16.0'
  gem 'beaker-puppet_install_helper', '~> 0.9.7'    
  gem 'beaker-rspec', '~> 6.2.4'
  gem 'beaker-vagrant', '~> 0.6.2'
  gem 'vagrant-wrapper', '~> 2.0.3' 
  # No Lockfile added to repo...
  gem 'minitest', '~> 5.4.3'
  gem 'multipart-post', '~> 2.3.0'
  gem 'beaker-hostgenerator', '~> 1.18.1'
  gem 'rexml', '~> 3.2.5'
  gem 'rspec-its', '~> 1.3.1'
  gem 'net-ssh', '~> 4.0'
  gem 'thor', '~> 0.19'
  # ED25519 support
  gem 'rbnacl', '~> 4.0.2'
  gem 'rbnacl-libsodium', '~> 1.0.16'
  gem 'ffi', '~> 1.15.5'
  gem 'bcrypt_pbkdf', '~> 1.1.1'
end

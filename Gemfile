source 'https://rubygems.org'

gem 'puppet', ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}" : '>= 4.6'

gem 'rake'
gem 'rspec', '~> 3.0'
gem 'rspec-puppet', '~> 2.3'
gem 'puppetlabs_spec_helper', '>= 2.1.1'
gem 'beaker-rspec', {"groups"=>["system_tests"]}
gem 'beaker-module_install_helper', {"groups"=>["system_tests"]}
gem 'beaker-puppet_install_helper', {"groups"=>["system_tests"]}
gem 'metadata-json-lint'

# vim:ft=ruby

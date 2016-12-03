source ENV['GEM_SOURCE'] || 'https://rubygems.org'
puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 3.8']

group :test do
  gem 'coveralls',              require: false
  gem 'facter',                 '>= 1.7.0'
  gem 'hiera',                  require: false
  gem 'httparty',               require: false
  gem 'metadata-json-lint',     require: false
  gem 'puppet',                 puppetversion
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-lint',            require: false
  gem 'puppet-strings',         require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'rake',                   require: false
  gem 'rspec-puppet',           '>= 2.3.2'
  gem 'rspec-puppet-utils',     require: false
  gem 'rspec_junit_formatter',  require: false
  gem 'rubocop'                 if RUBY_VERSION >= '2.0.0'
  gem 'rubocop-rspec',          '~> 1.6' if RUBY_VERSION >= '2.3.0'
  gem 'travis',                 require: false
  gem 'travis-lint',            require: false
  gem 'yard',                   require: false
end

group :acceptance do
  gem 'aws-sdk-core'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-rspec'
  gem 'git', '1.3.0'
  gem 'httparty'
  gem 'pry'
  gem 'retries'
end

group :development do
  gem 'notes', '~> 0.1.2'
end

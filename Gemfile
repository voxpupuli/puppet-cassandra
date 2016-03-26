source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']

if puppetversion
  gem 'puppet', puppetversion, require: false
else
  gem 'puppet', require: false
end

gem 'facter', '>= 1.7.0'

group :system_tests do
  gem 'backports',              '3.6.8'
  gem 'beaker',                 '2.33.0'
  gem 'beaker-rspec',           require: false
  gem 'coveralls',              require: false
  gem 'docker-api',             require: false
  gem 'fog',                    require: false
  gem 'fog-google',             '<= 0.0.9'
  gem 'hiera',                  require: false
  gem 'metadata-json-lint',     require: false
  gem 'pry',                    require: false
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-lint',            require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'rake',                   '<= 10.5.0'
  gem 'rspec_junit_formatter',  '0.2.2'
  gem 'rspec-puppet',           '<= 2.3.2'
  gem 'rspec-puppet-utils',     require: false
  gem 'rubocop',                require: false
  gem 'serverspec',             require: false
  gem 'travis',                 require: false
  gem 'travis-lint',            require: false
end

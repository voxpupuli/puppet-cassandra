source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']

if puppetversion
  gem 'puppet', puppetversion, require: false
else
  gem 'puppet', require: false
end

net_ssh_version = ENV['NET_SSH_GEM_VERSION']

if net_ssh_version
  gem 'net-ssh',
      net_ssh_version,
      require: false
end

tinsversion = ENV['TINS_GEM_VERSION']

if tinsversion
  gem 'tins',
      tinsversion,
      require: false
end

net_http_persistent_version = ENV['NET_HTTP_PERSISTENT_GEM_VERSION']

if net_http_persistent_version
  gem 'net_http_persistent',
    net_http_persistent_version,
    require: false
end

group :system_tests do
  gem 'beaker',                 require: false
  gem 'beaker-rspec',           require: false
  gem 'coveralls',              require: false
  gem 'docker-api',             require: false
  gem 'facter',                 '>= 1.7.0'
  gem 'fog',                    require: false
  gem 'hiera',                  require: false
  gem 'metadata-json-lint',     require: false
  gem 'pry',                    require: false
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-lint',            require: false
  gem 'puppet-strings',
      git: 'https://github.com/puppetlabs/puppet-strings.git'
  gem 'puppetlabs_spec_helper', require: false
  gem 'rake',                   require: false
  gem 'rspec_junit_formatter',  require: false
  gem 'rspec-puppet',           require: false
  gem 'rspec-puppet-utils',     require: false
  gem 'rubocop',                require: false
  gem 'serverspec',             require: false
  gem 'travis',                 require: false
  gem 'travis-lint',            require: false
  gem 'yard',                   require: false
end

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def gem_env_ver(gemname)
  environment_var = gemname.upcase + '_GEM_VERSION'
  environment_var = environment_var.tr('-', '_')

  gemversion = ENV[environment_var]

  if gemversion
    gem gemname, gemversion, require: false
  else
    gem gemname, require: false
  end
end

gem_env_ver('puppet')

group :test do
  gem 'coveralls',              require: false
  gem 'facter',                 '>= 1.7.0'
  gem 'hiera',                  require: false
  gem 'metadata-json-lint',     require: false
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-lint',            require: false
  gem 'puppet-strings',         require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'rake',                   require: false
  gem 'rspec_junit_formatter',  require: false
  gem 'rspec-puppet-utils',     require: false
  gem 'travis',                 require: false
  gem 'travis-lint',            require: false
  gem 'yard',                   require: false
end

group :system_tests do
  gem 'beaker-rspec'
  gem 'beaker-puppet_install_helper'
end

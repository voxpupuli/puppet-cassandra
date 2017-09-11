source ENV['GEM_SOURCE'] || 'https://rubygems.org'
puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['~> 4.0']

# github_changelog_generator must be 1.13.0 for ruby < 2.2.2
github_changelog_generator_version = RUBY_VERSION < '2.2.2' ? '~> 1.13.0' : '>= 1.13.0'

# github_changelog_generator must be 1.13.0 for ruby < 2.2.2
github_changelog_generator_version = RUBY_VERSION < '2.2.2' ? '~> 1.13.0' : '>= 1.13.0'

group :test do
  gem 'coveralls',              require: false
  gem 'facter',                 '>= 1.7.0'
  gem 'git',                    '1.3.0'
  gem 'github_changelog_generator', github_changelog_generator_version
  gem 'hiera',                  require: false
  gem 'httparty',               require: false
  gem 'metadata-json-lint',     require: false
  gem 'puppet',                 puppetversion
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-lint',            require: false
  gem 'puppet-strings',         require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'rack', '~> 1.0', require: false if RUBY_VERSION < '2.2.2'
  gem 'rspec-puppet', '>= 2.3.2'
  gem 'rspec-puppet-utils', require: false
  gem 'rspec_junit_formatter', require: false
  gem 'rubocop-rspec', '1.4.1' if RUBY_VERSION < '2.2.0'
  gem 'semantic_puppet',       require: false
  gem 'travis', require: false
  gem 'travis-lint', require: false
  gem 'yard', require: false
end

group :acceptance do
  gem 'beaker'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-rspec'
  gem 'pry'
end

group :development do
  gem 'notes', '~> 0.1.2'
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rake', '~> 10.0'
  gem 'rspec', '~> 2.0'
else
  # rubocop requires ruby >= 1.9
  gem 'rubocop'
end

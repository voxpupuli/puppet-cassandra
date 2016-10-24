require 'rubygems'
require 'rspec-puppet'
require 'rspec-puppet-utils'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'simplecov'
require 'coveralls'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |config|
  config.module_path = File.join(fixture_path, 'modules')
  config.manifest_dir = File.join(fixture_path, 'manifests')
  config.tty = true
  config.mock_with :rspec
  config.raise_errors_for_deprecations!
end

Coveralls.wear!
at_exit { RSpec::Puppet::Coverage.report! }

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

  config.before(:each) do
    MockFunction.new('concat') do |f|
    end

    MockFunction.new('count') do |f|
    end

    MockFunction.new('create_ini_settings') do |f|
    end

    MockFunction.new('delete') do |f|
    end

    MockFunction.new('is_array') do |f|
      f.stubbed.with('').returns(false)
      f.stubbed.with(['/var/lib/cassandra/data']).returns(true)
    end

    MockFunction.new('join') do |f|
    end

    MockFunction.new('join_keys_to_values') do |f|
    end

    MockFunction.new('merge') do |f|
    end

    MockFunction.new('prefix') do |f|
    end

    MockFunction.new('size') do |f|
    end

    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end

    MockFunction.new('validate_hash') do |f|
    end
  end
end

Coveralls.wear!
at_exit { RSpec::Puppet::Coverage.report! }

require 'rubygems'
require 'rspec-puppet'
require 'rspec-puppet-utils'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'simplecov'
require 'coveralls'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')

  c.before(:each) do
    MockFunction.new('concat') do |f|
      f.stubbed.returns([8888, 22])
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
    end

    MockFunction.new('is_hash') do |f|
      f.stubbed.with('').returns(false)
    end
  end
end

Coveralls.wear!
at_exit { RSpec::Puppet::Coverage.report! }

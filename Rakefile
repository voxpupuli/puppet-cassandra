require 'metadata-json-lint/rake_task'
require 'puppet/vendor/semantic/lib/semantic'
require 'puppet_blacksmith/rake_tasks'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rubocop/rake_task'
require 'rubygems'

# Use a custom pattern with git tag. %s is replaced with the version number.
Blacksmith::RakeTask.new do |t|
  t.tag_pattern = '%s'
end

RuboCop::RakeTask.new

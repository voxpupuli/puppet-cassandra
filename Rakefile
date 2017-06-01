require 'github_changelog_generator/task'
require 'metadata-json-lint/rake_task'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-strings/tasks'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rubocop/rake_task' if RUBY_VERSION >= '2.0.0'
require 'rubygems'

# TravisCI does not require the extra module tasks.
require_relative 'rake/rake_tasks'

# Use a custom pattern with git tag. %s is replaced with the version number.
Blacksmith::RakeTask.new do |t|
  t.tag_pattern = '%s'
end

exclude_paths = [
  'vagrant/**/*',
  'vendor/bundle/**/*'
]

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  version = Blacksmith::Modulefile.new.version
  config.future_release = version.to_s
  config.unreleased_only = true
  config.user = 'locp'
  config.project = 'cassandra'
end

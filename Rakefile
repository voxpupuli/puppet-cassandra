require 'puppet_blacksmith/rake_tasks'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rubygems'

Blacksmith::RakeTask.new do |t|
  t.tag_pattern = "%s" # Use a custom pattern with git tag. %s is replaced with the version number.
end

Rake::Task["lint"].enhance do
  Rake::Task["rubocop"].invoke
end

task :rubocop do
  sh 'rubocop'
end

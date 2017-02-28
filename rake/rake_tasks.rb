#############################################################################
# Some module specific rake tasks.
#############################################################################
require 'fileutils'
require_relative 'tasks/deploy'

desc '[CI Only] Run beaker, but only for pull requests or for release branches.'
task :acceptance do
  travis_pull_request = ENV['TRAVIS_PULL_REQUEST']

  if travis_pull_request.nil? || (travis_pull_request == 'false')
    puts 'Skipping acceptance tests.'
    exit(0)
  else
    Rake::Task['beaker'].invoke
  end
end

desc '[CI Only] Tag, build and push the module to PuppetForge.'
task :deploy do
  abort('Only deploy from master.') unless ENV['CIRCLE_BRANCH'] == 'master'

  # Find out what the local version of the module is.
  file = File.read('metadata.json')
  data_hash = JSON.parse(file)
  local_version = data_hash['version']
  abort('Unable to find local module version.') unless local_version
  puts "Module version (local): #{local_version}"

  Rake::Task['deploy:tag'].invoke(local_version)
  Rake::Task['deploy:forge'].invoke(local_version)
end

desc 'Run metadata_lint, rubocop, lint, validate and spec.'
task test: [
  :metadata_lint,
  :rubocop,
  :lint,
  :validate,
  :spec
]

desc 'Clean up after a vagrant run.'
task :vagrant_clean do
  module_root = File.expand_path(File.join(__FILE__, '..', '..'))
  directory = File.expand_path(File.join(module_root, 'vagrant', 'modules'))
  FileUtils.rm_r directory if File.directory?(directory)
end

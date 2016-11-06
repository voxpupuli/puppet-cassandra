#############################################################################
# Some module specific rake tasks.
#############################################################################
require 'httparty'
require 'json'

require_relative 'tasks/deploy'

task default: ['test']

desc '[CI Only] Run acceptance tests.'
task :acceptance do
  # Ensure we're on CircleCI and using the master branch.
  branch_name = ENV['CIRCLE_BRANCH']

  abort('CIRCLE_BRANCH not set.') unless branch_name

  unless branch_name.start_with?('release-')
    puts "#{branch_name} is not a release branch."
    exit(0)
  end
end

desc '[CI Only] Tag, build and push the module to PuppetForge.'
task :deploy do
  # Ensure we're on CircleCI and using the master branch.
  branch_name = ENV['CIRCLE_BRANCH']

  if !branch_name
    abort('CIRCLE_BRANCH not set.')
  elsif branch_name != 'master'
    abort("Only deploy from master. Branch name: #{branch_name}")
  end

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

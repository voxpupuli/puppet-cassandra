#############################################################################
# Some module specific rake tasks.
#############################################################################
require_relative 'tasks/deploy'

desc '[CI Only] Run beaker, but only for pull requests or for release branches.'
task :acceptance do
  skip = true
  travis_branch = ENV['TRAVIS_BRANCH']
  travis_event_type = ENV['TRAVIS_EVENT_TYPE']

  if travis_event_type == 'pull_request'
    skip = false
  elsif travis_event_type == 'push'
    skip = false if travis_branch =~ /^release-/ || travis_branch =~ /^hotfix-/
  end

  if skip
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

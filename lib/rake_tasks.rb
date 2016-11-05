#############################################################################
# Some module specific rake tasks.
#############################################################################
require 'httparty'
require 'json'

task default: ['test']

desc '[CI Only] Run acceptance tests.'
task :acceptance do
  # Ensure we're on CircleCI and using the master branch.
  branch_name = ENV['CIRCLE_BRANCH']

  if !branch_name
    abort('CIRCLE_BRANCH not set.')
  end

  if !branch_name.start_with?('release-')
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
    abort("Only deploy from master [#{branch_name}]")
  end

  # Find out what the local version of the module is.
  file = File.read('metadata.json')
  data_hash = JSON.parse(file)
  local_version = data_hash['version']
  abort('Version not found in metadata.json.') unless local_version
  puts "Local version: #{local_version}"

  # Find out what the forge version of the module is.
  response = HTTParty.get('https://forgeapi.puppetlabs.com/v3/modules/locp-cassandra')
  data_hash = JSON.parse(response.body)
  forge_version = data_hash['current_release']['version']
  abort('Unable to find out the forge version.') unless forge_version
  puts "Forge version: #{forge_version}"
end

desc 'Run metadata_lint, rubocop, lint, validate and spec.'
task test: [
  :metadata_lint,
  :rubocop,
  :lint,
  :validate,
  :spec
]

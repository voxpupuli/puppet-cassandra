#############################################################################
# Some module specific rake tasks.
#############################################################################
require_relative 'tasks/deploy'

task default: ['test']

# Validate that we are running on a valide CircleCI branch.  Exit false
# if we do not seem to be on a CircleCI build at all or if the branch
# name does not match a provided pattern.
def validate_branch(valid_branch_pattern)
  branch_name = ENV['CIRCLE_BRANCH']
  return false unless branch_name
  return false unless branch_name =~ valid_branch_pattern
  true
end

# Check to see if acceptance is enabled.
def acceptance_enabled
  acceptance = ENV['ACCEPTANCE']
  return false unless acceptance
end

desc '[CI Only] Run acceptance tests.'
task :acceptance do
  unless acceptance_enabled
    puts 'Acceptance is not enabled.'
    exit(0)
  end

  unless validate_branch(/^release-/) || validate_branch(/^hotfix-/)
    puts 'Not a release or hotfix branch.'
    exit(0)
  end

  stdout = `bundle exec rake beaker:sets | xargs`
  sets = stdout.split(' ')
  node_total = ENV['CIRCLE_NODE_TOTAL'].to_i
  node_index = ENV['CIRCLE_NODE_INDEX'].to_i
  nodes = []
  l = sets.length - 1

  (0..l).each do |i|
    nodes << sets[i] if (i % node_total) == node_index
  end

  unless nodes.length
    puts 'No nodes configured for this node.'
    exit(0)
  end
end

desc '[CI Only] Tag, build and push the module to PuppetForge.'
task :deploy do
  abort('Only deploy from master.') unless validate_branch(/^master-/)

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

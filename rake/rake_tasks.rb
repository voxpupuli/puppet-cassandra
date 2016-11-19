#############################################################################
# Some module specific rake tasks.
#############################################################################
require_relative 'tasks/acceptance'
require_relative 'tasks/deploy'

task default: ['test']

# Validate that we are running on a valide CircleCI branch.  Exit false
# if we do not seem to be on a CircleCI build at all or if the branch
# name does not match a provided pattern.
def validate_branch(valid_branch_pattern)
  branch_name = ENV['CIRCLE_BRANCH']

  unless branch_name
    puts 'CIRCLE_BRANCH is not set.'
    return false
  end

  unless branch_name =~ valid_branch_pattern
    puts "Branch #{branch_name} is not suitable for this operation."
    return false
  end

  true
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

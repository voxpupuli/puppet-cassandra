#############################################################################
# Some module specific rake tasks.
#############################################################################
require_relative 'tasks/deploy'

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

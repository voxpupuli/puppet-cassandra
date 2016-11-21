require 'httparty'
require 'json'
require 'yaml'

namespace :deploy do
  desc 'Deploy module to Puppet Forge if required.'
  task :forge, [:version] do |_t, args|
    local_version = args[:version]

    # Find out what the forge version of the module is.
    response = HTTParty.get('https://forgeapi.puppetlabs.com/v3/modules/locp-cassandra')
    data_hash = JSON.parse(response.body)
    forge_version = data_hash['current_release']['version']
    abort('Unable to find out the forge version.') unless forge_version
    puts "Module version (forge): #{forge_version}"
    exit 0 unless local_version != forge_version

    # Build the module.
    puts "Build and deploy version #{local_version}."
    Rake::Task['module:clean'].invoke
    Rake::Task['build'].invoke

    # Now see if we can push this baby to the forge.
    PUPPET_FORGE_CREDENTIALS_FILE = ENV['HOME'] + '/' + '.puppetforge.yml'
    username = ENV['CIRCLE_PROJECT_USERNAME']
    password = ENV['PUPPET_FORGE_PASSWORD']
    abort("Not enough data to populate #{PUPPET_FORGE_CREDENTIALS_FILE}") unless username && password
    puts "Populating #{PUPPET_FORGE_CREDENTIALS_FILE}"
    credentials = { 'username' => username, 'password' => password }
    File.open(PUPPET_FORGE_CREDENTIALS_FILE, 'w') { |f| f.write credentials.to_yaml }
    Rake::Task['module:push'].invoke
  end
end

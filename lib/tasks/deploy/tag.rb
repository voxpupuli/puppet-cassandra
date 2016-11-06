require 'git'

namespace :deploy do
  desc 'Deploy tag for the module'
  task :tag, [:version] do |_t, args|
    tagname = args[:version]
    # Find out if a tag is available for this version.
    log = Logger.new(STDOUT)
    log.level = Logger::WARN
    git = Git.open('.', log: log)

    begin
      git.tag(tagname)
    rescue Git::GitTagNameDoesNotExist
      puts "Creating tag: #{tagname}"
      git.add_tag(tagname, 'master', message: 'tagged by RubyAutoDeployTest', f: true)
      git.push('origin', "refs/tags/#{tagname}", f: true)
    else
      puts "Tag: #{tagname} already exists."
    end
  end
end

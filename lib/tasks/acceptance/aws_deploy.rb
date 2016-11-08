namespace :acceptance do
  desc 'Deploy a docker node in AWS.'
  task :aws_deploy do
    unless aws_acceptance_enabled
      puts 'AWS acceptance tests are not enabled.'
      exit(0)
    end

    init_pp = generate_manifest('present')
    puppet_apply(init_pp)
  end
end

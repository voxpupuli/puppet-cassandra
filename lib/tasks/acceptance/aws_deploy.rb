namespace :acceptance do
  desc 'Deploy a docker node in AWS.'
  task :aws_deploy do
    unless aws_acceptance_enabled
      puts 'AWS acceptance tests are not enabled.'
      exit(0)
    end
  end
end

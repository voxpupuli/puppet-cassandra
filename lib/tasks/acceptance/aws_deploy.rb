namespace :acceptance do
  desc 'Deploy a docker node in AWS.'
  task :aws_deploy do
    exit(0) unless ec2_acceptance_enabled
    node_index = ENV['CIRCLE_NODE_INDEX']

    unless node_index == '0'
      puts 'Not on the primary CIRCLE_NODE'
      exit(0)
    end

    puppet_apply
  end
end

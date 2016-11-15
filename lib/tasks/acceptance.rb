require 'tempfile'

require_relative 'acceptance/aws_deploy'
require_relative 'acceptance/tests'

# Check to see if acceptance is enabled.
def acceptance_enabled
  acceptance = ENV['ACCEPTANCE']

  unless acceptance == 'true'
    echo 'Either ACCEPTANCE is not set or is "false".'
    return false
  end

  true
end

# Check to see if AWS acceptance is enabled.
def ec2_acceptance_enabled
  ec2_acceptance = ENV['EC2_ACCEPTANCE']

  unless ec2_acceptance == 'true'
    echo 'Either EC2_ACCEPTANCE is not set or is "false".'
    return false
  end

  true
end

def puppet_apply(_manifest)
  system 'puppet apply lib/puppet/init.pp --test'
  return_status = $CHILD_STATUS.exitstatus
  exit(return_status) unless return_status.zero? || return_status == 2
end

def test_node(hypervisor, node)
  if hypervisor == 'docker'
    cmd = "BEAKER_destroy=no BEAKER_set=#{node} bundle exec rake beaker"
  else
    return 0 unless ec2_acceptance_enabled
    cmd = "BEAKER_set=#{node} bundle exec rake beaker"
  end

  puts cmd
end

def test_nodes(nodes)
  nodes.each do |node|
    a = node.split('_')
    test_node(a[0], node)
  end
end

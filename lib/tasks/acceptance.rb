require 'tempfile'

require_relative 'acceptance/aws_deploy'
require_relative 'acceptance/tests'

# Check to see if acceptance is enabled.
def acceptance_enabled
  acceptance = ENV['ACCEPTANCE']
  return false unless acceptance == 'true'
  true
end

# Check to see if AWS acceptance is enabled.
def aws_acceptance_enabled
  aws_acceptance = ENV['AWS_ACCEPTANCE']
  return false unless aws_acceptance == 'true'
  true
end

def puppet_apply(_manifest)
  system 'puppet apply lib/puppet/init.pp --test'
  return_status = $CHILD_STATUS.exitstatus
  exit(return_status) unless return_status.zero? || return_status == 2
end

def test_nodes(nodes)
  nodes.each do |node|
    puts "Testing #{node}"
  end
end

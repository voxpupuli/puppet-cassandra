require 'tempfile'

require_relative 'acceptance/aws_deploy'
require_relative 'acceptance/aws_destroy'
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

def circle_igw(ensure_action, region)
  <<-EOS
    ec2_vpc_internet_gateway { 'circleci-igw':
      ensure => #{ensure_action}',
      region => '#{region}',
      vpc    => 'circleci-vpc',
    }
  EOS
end

def circleci_routes(ensure_action, region)
  <<-EOS
    ec2_vpc_routetable { 'circleci-routes':
      ensure => #{ensure_action}',
      region => '#{region}',
      vpc    => 'circleci-vpc',
      routes => [ { destination_cidr_block => '10.0.0.0/16', gateway => 'local' },
        { destination_cidr_block => '0.0.0.0/0', gateway => 'circleci-igw' }, ],
    }
  EOS
end

def circleci_sg(ensure_action, region)
  <<-EOS
    ec2_securitygroup { 'circleci-sg':
      ensure      => #{ensure_action}',
      region      => '#{region}',
      vpc         => 'circleci-vpc',
      description => 'Security group for VPC',
      ingress     => [{
        security_group => 'circleci-sg',
      },{
        protocol => 'tcp',
        port     => 22,
        cidr     => '0.0.0.0/0'
      }]
    }
  EOS
end

def circleci_subnet(ensure_action, region)
  <<-EOS
    ec2_vpc_subnet { 'circleci-subnet':
      ensure            => #{ensure_action}',
      region            => '#{region}',
      vpc               => 'circleci-vpc',
      cidr_block        => '10.0.0.0/24',
      availability_zone => $region,
      route_table       => 'circleci-routes',
    }
  EOS
end

def circleci_vpc(ensure_action, region)
  <<-EOS
    ec2_vpc { 'circleci-vpc':
      ensure       => #{ensure_action}',
      region       => '#{region}',
      cidr_block   => '10.0.0.0/16',
    }
  EOS
end

def generate_manifest(ensure_action)
  region = 'eu-west-1'
  manifest_pp = circleci_vpc(ensure_action, region)
  manifest_pp << circleci_sg(ensure_action, region)
  manifest_pp << circleci_subnet(ensure_action, region)
  manifest_pp << circle_igw(ensure_action, region)
  manifest_pp << circleci_routes(ensure_action, region)
  manifest_pp
end

def puppet_apply(manifest)
  t = Tempfile.new('apply_pp.')
  t << manifest
  t.close
  puts `puppet apply #{t.path} --test`
end

def test_nodes(nodes)
  nodes.each do |node|
    puts "Testing #{node}"
  end
end

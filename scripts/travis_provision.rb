require 'rubygems'
require 'fog'

# create a connection
ec2 = Fog::Compute.new(provider: 'AWS',
                       region: 'eu-west-1')

response = ec2.run_instances(
  'ami-b056e9c3',
  1,
  1,
  'InstanceType'  => 'c4.xlarge',
  'SecurityGroup' => 'ssh',
  'KeyName'       => 'travis'
)

instance_id = response.body['instancesSet'].first['instanceId']
instance = ec2.servers.get(instance_id)
instance.wait_for { ready? }
puts instance_id, ':', instance.public_ip_address

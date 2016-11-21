#############################################################################
# We removed default VPC's from out AWS configuration.  Unless a VPC is
# specified to Beaker AWS it will fail if there is no default.  This manifest
# is simply a creation setup for what is required for beaker.  When this has
# been created, ensure that the subnet is specified in the node file.
#############################################################################
$account_name = 'Beaker-1025093278'
$region = 'eu-west-1'

ec2_vpc_dhcp_options { $account_name:
  ensure              => present,
  region              => $region,
  domain_name         => $domain_name,
  domain_name_servers => ['8.8.8.8', '8.8.4.4'],
}

ec2_vpc { $account_name:
  ensure       => present,
  cidr_block   => '10.0.0.0/16',
  dhcp_options => $account_name,
  region       => $region,
}

ec2_vpc_internet_gateway { "${account_name}-igw":
  ensure => $ensure,
  region => $region,
  vpc    => $account_name,
}

ec2_vpc_routetable { "${account_name}-rtb":
  ensure => $ensure,
  region => $region,
  routes => [
    {
      'destination_cidr_block' => '10.0.0.0/16',
      'gateway'                => 'local',
    },
    {
      'destination_cidr_block' => '0.0.0.0/0',
      'gateway'                => "${account_name}-igw",
    }
  ],
  vpc    => $account_name,
}


ec2_vpc_subnet { $account_name:
  ensure                  => present,
  availability_zone       => "${region}a",
  cidr_block              => '10.0.0.0/20',
  region                  => $region,
  route_table             => "${account_name}-rtb",
  vpc                     => $account_name,
  map_public_ip_on_launch => true,
}

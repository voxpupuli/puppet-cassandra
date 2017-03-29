# An optional class that will allow a suitable repository to be configured
# from which packages for Apache Cassandra can be downloaded.  Changing
# the defaults will allow any Debian Apt or Red Hat Yum repository to be
# configured.

class cassandra::apache_repo (
  $descr   = 'Repo for Apache Cassandra',
  $key_id  = 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
  $key_url = 'https://www.apache.org/dist/cassandra/KEYS',
  $pkg_url = 'http://www.apache.org/dist/cassandra/debian',
  $release = '310x',
  ) {
  case $::osfamily {
    'Debian': {
      include apt
      include apt::update

      apt::key {'apachekey':
        id     => $key_id,
        source => $key_url,
        before => Apt::Source['apache'],
      }


      apt::source {'apache':
        location => $pkg_url,
        comment  => $descr,
        release  => $release,
        include  => {
          'src' => false,
        },
        notify   => Exec['update-cassandra-repos'],
      }

      # Required to wrap apt_update
      exec {'update-cassandra-repos':
        refreshonly => true,
        command     => '/bin/true',
        require     => Exec['apt_update'],
      }
    }
    default: {
      warning("OS ${::osfamily} not supported")
    }
  }
}

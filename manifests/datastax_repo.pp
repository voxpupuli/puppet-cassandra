# An optional class that will allow a suitable repository to be configured
# from which packages for DataStax Community can be downloaded.  Changing
# the defaults will allow any Debian Apt or Red Hat Yum repository to be
# configured.
#
class cassandra::datastax_repo (
  $descr   = 'DataStax Repo for Apache Cassandra',
  $key_id  = '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
  $key_url = 'http://debian.datastax.com/debian/repo_key',
  $pkg_url = undef,
  $release = 'stable',
  ) {
  case $::osfamily {
    'RedHat': {
      if $pkg_url != undef {
        $baseurl = $pkg_url
      } else {
        $baseurl = 'http://rpm.datastax.com/community'
      }

      yumrepo { 'datastax':
        ensure   => present,
        descr    => $descr,
        baseurl  => $baseurl,
        enabled  => 1,
        gpgcheck => 0,
      }
    }
    'Debian': {
      include apt
      include apt::update

      apt::key {'datastaxkey':
        id     => $key_id,
        source => $key_url,
        before => Apt::Source['datastax'],
      }

      if $pkg_url != undef {
        $location = $pkg_url
      } else {
        $location = 'http://debian.datastax.com/community'
      }

      apt::source {'datastax':
        location => $location,
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
      warning("OS family ${::osfamily} not supported")
    }
  }
}

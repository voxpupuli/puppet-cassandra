# An optional class that will allow a suitable repository to be configured
# from which packages for Apache Cassandra can be downloaded.  Changing
# the defaults will allow any Debian Apt repository to be configured.
# Currently Apache only provide a Debian repository
# (http://cassandra.apache.org/download/) mentions of Yum are for wishful
# thinking.
# @param descr [string] On the Red Hat family, this is passed as the `descr`
#   attribute to a `yumrepo` resource.  On the Debian family, it is passed as
#   the `comment` attribute to an `apt::source` resource.
# @param key_id [string] On the Debian family, this is passed as the `id`
#   attribute to an `apt::key` resource.  On the Red Hat family, it is
#   ignored.
# @param key_url [string] On the Debian family, this is passed as the
#   `source` attribute to an `apt::key` resource.  On the Red Hat family,
#   it is ignored.
# @param pkg_url [string] If left as the default, this will set the `baseurl`
#   to 'http://rpm.datastax.com/community' on a `yumrepo` resource
#   on the Red Hat family.  On the Debian family, leaving this as the default
#   will set the `location` attribute on an `apt::source` to
#   'http://www.apache.org/dist/cassandra/debian'.
# @param release [string] On the Debian family, this is passed as the `release`
#   attribute to an `apt::source` resource.  On the Red Hat family, it is
#   ignored.
class cassandra::apache_repo (
  $descr   = 'Repo for Apache Cassandra',
  $key_id  = 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
  $key_url = 'https://www.apache.org/dist/cassandra/KEYS',
  $pkg_url = undef,
  $release = 'main',
  ) {
  case $::osfamily {
    'Debian': {
      include apt
      include apt::update

      apt::key {'apache.cassandra':
        id     => $key_id,
        source => $key_url,
        before => Apt::Source['cassandra.sources'],
      }

      if $pkg_url != undef {
        $location = $pkg_url
      } else {
        $location = 'http://www.apache.org/dist/cassandra/debian'
      }

      apt::source {'cassandra.sources':
        location => $location,
        comment  => $descr,
        release  => $release,
        include  => {
          'src' => false,
        },
        notify   => Exec['update-apache-cassandra-repo'],
      }

      # Required to wrap apt_update
      exec {'update-apache-cassandra-repo':
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
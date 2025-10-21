# @api private
#
# @summary This class is called from cassandra for install.
#
class cassandra::install {
  if $cassandra::manage_user {
    group { $cassandra::group:
      ensure => present,
      gid    => $cassandra::gid,
      system => $cassandra::system_group,
    }
    -> user { $cassandra::user:
      ensure     => present,
      gid        => $cassandra::gid,
      uid        => $cassandra::uid,
      system     => $cassandra::system_user,
      home       => $cassandra::homedir,
      shell      => $cassandra::shell,
      managehome => $cassandra::manage_homedir,
    }
  }

  case $facts['os']['family'] {
    'RedHat': {
      if $cassandra::manage_repo {
        $cassandra::repo_config.each | String $_repo_name, Hash $_attributes| {
          yumrepo { $_repo_name:
            *      => $_attributes,
            before => [
              Package[$cassandra::package_name],
              Package[$cassandra::tools_package]
            ],
          }
        }
      }
    }
    'Debian': {
      if $cassandra::manage_repo {
        $cassandra::repo_config.each | String $_repo_name, Hash $_attributes| {
          apt::source { $_repo_name:
            *      => $_attributes,
            before => [
              Package[$cassandra::package_name],
              Package[$cassandra::tools_package]
            ],
          }
        }
      }

      Class['Apt::Update']
      -> Package[$cassandra::package_name]
      -> Package[$cassandra::tools_package]
    }
    default: {
      fail("OS family ${facts['os']['family']} not supported")
    }
  }

  if $cassandra::java_package {
    package { $cassandra::java_package:
      ensure => $cassandra::java_ensure,
    }
  }

  if $cassandra::jna_package {
    package { $cassandra::jna_package:
      ensure => $cassandra::jna_ensure,
    }
  }

  package { $cassandra::package_name:
    ensure => $cassandra::package_ensure,
  }

  package { $cassandra::tools_package:
    ensure => $cassandra::tools_ensure,
  }
}

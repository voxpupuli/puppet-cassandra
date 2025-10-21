# @api private
#
# @summary This class is called from cassandra to manage the service.
#
class cassandra::service {
  if $cassandra::manage_service {
    service { $cassandra::service_name:
      ensure => $cassandra::service_ensure,
      enable => $cassandra::service_enable,
    }
  }
}

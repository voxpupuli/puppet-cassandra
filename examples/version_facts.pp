if $::cassandrarelease {
  notify { "Cassandra release: ${::cassandrarelease}": } ->
  notify { "Cassandra major version: ${::cassandramajorversion}": } ->
  notify { "Cassandra minor version: ${::cassandraminorversion}": } ->
  notify { "Cassandra patch version: ${::cassandrapatchversion}": }
}

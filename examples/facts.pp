if $facts['cassandrarelease'] {
  notify { "Cassandra release: ${facts['cassandrarelease']}": }
} else {
  warning('fact cassandrarelease is not set!')
}

if $facts['cassandramajorversion'] {
  notify { "Cassandra major version: ${facts['cassandramajorversion']}": }
} else {
  warning('fact cassandramajorversion is not set!')
}

if $facts['cassandraminorversion'] {
  notify { "Cassandra minor version: ${facts['cassandraminorversion']}": }
} else {
  warning('fact cassandraminorversion is not set!')
}

if $facts['cassandrapatchversion'] {
  notify { "Cassandra patch version: ${facts['cassandrapatchversion']}": }
} else {
  warning('fact cassandrapatchversion is not set!')
}

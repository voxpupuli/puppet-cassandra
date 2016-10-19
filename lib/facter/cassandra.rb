# Extract the release string from the running Cassandra instance.
#
# @resolution
#   Runs the command "nodetool version".
# @caveats
#   The Cassandra service needs to be running, otherwise the fact will be
# undefined.
# @return [string] The version string (e.g. 3.0.1).
Facter.add('cassandrarelease') do
  setcode do
    version = Facter::Util::Resolution.exec('nodetool version')
    version.match(/\d+\.\d+\.\d+/).to_s if version && version != ''
  end
end

# Extract the major version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The major version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandramajorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[0].to_i if release
  end
end

# Extract the minor version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The minor version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandraminorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[1].to_i if release
  end
end

# Extract the patch version from the cassandrarelease fact.
# @caveats
#   Requires that the cassandrarelease has been successfully retrieved.
# @return [integer] The patch version of the Cassandra instance.
# @see cassandrarelease
Facter.add('cassandrapatchversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[2].to_i if release
  end
end

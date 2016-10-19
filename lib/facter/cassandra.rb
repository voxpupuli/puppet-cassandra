#############################################################################
# Gather details about the Cassandra installation.
#############################################################################

Facter.add('cassandrarelease') do
  setcode do
    version = Facter::Util::Resolution.exec('nodetool version')
    version.match(/\d+\.\d+\.\d+/).to_s if version && version != ''
  end
end

Facter.add('cassandramajorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[0].to_i if release
  end
end

Facter.add('cassandraminorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[1].to_i if release
  end
end

Facter.add('cassandrapatchversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[2].to_i if release
  end
end

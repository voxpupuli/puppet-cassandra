#############################################################################
# Gather details about the Cassandra installation.
#############################################################################

Facter.add('cassandrarelease') do
  cmd = '/bin/nodetool version'
  cmdoutput = `#{cmd} 2> /dev/null`

  setcode do
    if cmdoutput == ''
      nil
    else
      cmdoutput.split(': ')[1]
    end
  end
end

Facter.add('cassandramajorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[0]
  end
end

Facter.add('cassandraminorversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[1]
  end
end

Facter.add('cassandrapatchversion') do
  setcode do
    release = Facter.value(:cassandrarelease)
    release.split('.')[2]
  end
end

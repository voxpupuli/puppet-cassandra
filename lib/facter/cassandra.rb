# Returns a value (MB) that might be suitable to set the HEAP_NEWSIZE when using
# the Concurrent Mark Sweep (CMS) Collector.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] min(100 times the number of cores, 1/4 CMS MAX_HEAP_SIZE)
# @see cassandracmsmaxheapsize
# @see cassandramaxheapsize
# @see cassandracmsheapnewsize
Facter.add('cassandracmsheapnewsize') do
  setcode do
    maxheapsize = Facter.value(:cassandracmsmaxheapsize).to_f
    processorcount = Facter.value(:processorcount).to_f
    heapnewsize = [100 * processorcount, maxheapsize * 0.25].min
    heapnewsize.round
  end
end

# Returns a value (MB) that might be suitable to set the MAX_HEAP_SIZE when using
# the Concurrent Mark Sweep (CMS) Collector.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] max(min(1/2 ram, 1024), min(1/4 ram, 14336)
# @see cassandracmsheapnewsize
# @see cassandraheapnewsize
# @see cassandramaxheapsize
Facter.add('cassandracmsmaxheapsize') do
  setcode do
    memorysize_mb = Facter.value(:memorysize_mb).to_f
    calc1 = [memorysize_mb * 0.5, 1024].min
    calc2 = [memorysize_mb * 0.25, 14_336].min
    maxheapsize = [calc1, calc2].max
    maxheapsize.round
  end
end

# Returns a value (MB) that might be suitable to set the HEAP_NEWSIZE.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] min(100 times the number of cores, 1/4 MAX_HEAP_SIZE)
# @see cassandracmsheapnewsize
# @see cassandracmsmaxheapsize
# @see cassandramaxheapsize
Facter.add('cassandraheapnewsize') do
  setcode do
    maxheapsize = Facter.value(:cassandramaxheapsize).to_f
    processorcount = Facter.value(:processorcount).to_f
    heapnewsize = [100 * processorcount, maxheapsize * 0.25].min
    heapnewsize.round
  end
end

# Returns a value (MB) that might be suitable to set the MAX_HEAP_SIZE.
# See [Tuning Java resources]
# (https://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html)
# for more details.
#
# @return [integer] max(min(1/2 ram, 1024), min(1/4 ram, 8192)
# @see cassandracmsheapnewsize
# @see cassandracmsmaxheapsize
# @see cassandraheapnewsize
Facter.add('cassandramaxheapsize') do
  setcode do
    memorysize_mb = Facter.value(:memorysize_mb).to_f
    calc1 = [memorysize_mb * 0.5, 1024].min
    calc2 = [memorysize_mb * 0.25, 8192].min
    maxheapsize = [calc1, calc2].max
    maxheapsize.round
  end
end

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

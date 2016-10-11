Facter.add(:istmpexecutable) do
  setcode do
    # if cassandra is fully installed, test for +x and ACLs on /var/tmp
    if File.exists? '/etc/cassandra/conf/jvm.options'
      if File.stat("/var/tmp").executable_real?
        'true'
      end
      # cassandra is installed but we can't use /var/tmp
      'false'
    end
    # cassandra isn't installed yet
    'test is not ready yet'
  end
end

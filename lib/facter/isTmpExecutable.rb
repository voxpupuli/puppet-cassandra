Facter.add(:isTmpExecutable) do
  setcode do
    # if cassandra is fully installed, test for +x and ACLs on /var/tmp
    if File.stat("/etc/cassandra/conf/jvm.options").file?
      if File.stat("/var/tmp").executable_real?
        'true'
      end
      # cassandra is installed but we can't use /var/tmp
      'false'
    end
    'test is not ready yet'
  end
end

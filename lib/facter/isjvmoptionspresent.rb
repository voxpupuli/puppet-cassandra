Facter.add(:isjvmoptionspresent) do
  setcode do
    'false'
    if File.exists? '/etc/cassandra/conf/jvm.options'
      'true'
    end
  end
end

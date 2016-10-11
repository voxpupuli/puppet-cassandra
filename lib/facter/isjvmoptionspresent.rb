Facter.add(:isjvmoptionspresent) do
  setcode do
    if File.exists? '/etc/cassandra/conf/jvm.options'
      'true'
    else
      'false'
    end
  end
end

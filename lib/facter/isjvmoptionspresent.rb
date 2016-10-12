Facter.add(:isjvmoptionspresent) do
  setcode do
    if File.exist? '/etc/cassandra/conf/jvm.options'
      'true'
    else
      'false'
    end
  end
end

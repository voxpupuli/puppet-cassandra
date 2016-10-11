Facter.add(:istmpexecutable) do
  setcode do
    'false'
    if File.stat("/var/tmp").executable_real?
      'true'
    end
  end
end

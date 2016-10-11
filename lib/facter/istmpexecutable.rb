Facter.add(:istmpexecutable) do
  setcode do
    if File.stat('/var/tmp').executable_real?
      'true'
    else
      'false'
    end
  end
end

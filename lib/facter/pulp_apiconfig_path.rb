Facter.add("pulp_apiconfig_path") do
  setcode do
    File.join(Puppet[:vardir],"pulpapi.json")
  end
end

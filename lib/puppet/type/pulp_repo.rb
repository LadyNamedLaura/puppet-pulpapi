begin
  require 'puppet_x/inuits/pulp/type'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
end

Puppet::Type.newtype(:pulp_repo) do
  ensurable do
    newvalues :present, :absent
    defaultto :present
  end

  newparam(:name) do
    desc "Name of the repository"
  end

  newproperty(:display_name) do
    desc "User-readable display name. May contain i18n characters."
  end

  newproperty(:description) do
    desc "User-readable description. May contain i18n characters."
  end

  newproperty(:notes) do
  end
end

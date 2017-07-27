begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/pulpapiv2'
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
  autorequire(:file) do
    [PuppetX::Inuits::Pulp::APIv2.config_filename]
  end
end

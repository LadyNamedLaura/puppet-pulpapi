begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.newtype(:pulp_importer) do
  ensurable

  newparam(:repo, :namevar => true) do
  end
  newproperty(:type) do
  end
  newproperty(:config) do
  end
  autorequire(:file) do
    [PuppetX::Inuits::Pulp::APIv2.config_filename]
  end
  autorequire(:pulp_repo) do
    [self[:repo]]
  end
end

begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end
require 'puppet/property/boolean'

Puppet::Type.newtype(:pulp_distributor) do
  ensurable do
    newvalues :present, :absent
    defaultto :present
  end

  newparam(:repo) do
    isnamevar
  end
  newparam(:id) do
    isnamevar
  end
  newparam(:name) do
    def default
      self.resource[:id]
    end
    munge do |discard|
      self.resource[:id]
    end
#    isnamevar
  end
  newproperty(:type) do
  end
  newproperty(:config) do
  end
  newproperty(:auto_publish, :parent => Puppet::Property::Boolean) do
    defaultto false
  end
  def self.title_patterns
    PuppetX::Inuits::Pulp::Type.basic_split_title_patterns(:repo,:id)
  end
  autorequire(:file) do
    [PuppetX::Inuits::Pulp::PulpAPIv2.configpath]
  end
  autorequire(:pulp_repo) do
    [self[:repo]]
  end
end

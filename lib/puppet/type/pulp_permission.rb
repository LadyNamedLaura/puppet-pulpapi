begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.newtype(:pulp_permission) do
  ensurable do
    newvalues :present, :absent
    defaultto :present
  end

  newparam(:user) do
    isnamevar
  end
  newparam(:path) do
    isnamevar
  end
  newproperty(:operations, :array_matching => :all) do
    newvalues('CREATE','READ','UPDATE','DELETE','EXECUTE')
    def insync?(is)
      [is].flatten.sort == [@should].flatten.sort
    end
    munge do |v|
      v.to_s.upcase
    end
  end
  newparam(:name) do
    def default
      [self.resource[:user],self.resource[:path]].join('::')
    end
    munge do |discard|
      [self.resource[:user],self.resource[:path]].join('::')
    end
  end
  def self.title_patterns
    PuppetX::Inuits::Pulp::Type.basic_split_title_patterns(:user,:path)
  end
  autorequire(:file) do
    [PuppetX::Inuits::Pulp::PulpAPIv2.configpath]
  end
  autorequire(:pulp_user) do
    [self[:user]]
  end
end

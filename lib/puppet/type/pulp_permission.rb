begin
  require 'puppet_x/inuits/pulp/type'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
end

Puppet::Type.newtype(:pulp_permission) do
  ensurable

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
end

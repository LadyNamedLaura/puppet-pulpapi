begin
  require 'puppet_x/inuits/pulp/type'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
end

Puppet::Type.newtype(:pulp_importer) do
  ensurable

  newparam(:repo, :namevar => true) do
  end
  newparam(:name) do
    def default
      self.resource[:repo]
    end
    munge do |discard|
      self.resource[:repo]
    end
  end
  newproperty(:type) do
  end
  newproperty(:config) do
  end
  def self.title_patterns
    PuppetX::Inuits::Pulp::Type.basic_split_title_patterns(:repo,:type)
  end
  autorequire(:pulp_repo) do
    [@parameters[:repo]]
  end
end

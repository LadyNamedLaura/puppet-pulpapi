begin
  require 'puppet_x/inuits/pulp/type'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
end

Puppet::Type.newtype(:pulp_sync_schedule) do
  ensurable

  newparam(:repo) do
    isnamevar
  end
  newparam(:sched) do
    isnamevar
  end
  newparam(:name) do
    def default
      self.resource[:repo]
    end
    munge do |discard|
      self.resource[:repo]
    end
  end
  newproperty(:enabled) do
    defaultto true
  end
  newproperty(:override_config) do
    defaultto {}
  end
  def self.title_patterns
    PuppetX::Inuits::Pulp::Type.basic_split_title_patterns(:repo,:sched)
  end
  autorequire(:pulp_repo) do
    [@parameters[:repo]]
  end
  autorequire(:pulp_importer) do
    [@parameters[:repo]]
  end
end

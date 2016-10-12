begin
  require 'puppet_x/inuits/pulp/type'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
end

Puppet::Type.newtype(:pulp_repo) do
  ensurable

  newparam(:name) do
  end
  newproperty(:display_name) do
  end
  newproperty(:description) do
  end
  newproperty(:notes) do
  end
end

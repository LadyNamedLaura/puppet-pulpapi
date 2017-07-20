begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_permission).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :name          => [:user,:path],
      :path          => :path,
      :user          => :user,
      :operations    => :operations,
      :oldoperations => :oldoperations,
    }
  end

  def do_destroy
    api("permissions/actions/revoke_from_user", Net::HTTP::Post,{
      :login      => @property_hash[:user],
      :resource   => @property_hash[:path],
      :operations => [@property_hash[:oldoperations]].flatten,
    })
  end
  def do_create
    api('permissions/actions/grant_to_user', Net::HTTP::Post, {
      :login      => @property_hash[:user],
      :resource   => @property_hash[:path],
      :operations => [@property_hash[:operations]].flatten,
    })
  end

  def self.rawinstances
    api('permissions').map do |perm|
      unless ['/v2/actions/login/','/v2/actions/logout/'].include? perm['resource']
        perm['users'].map do |uname, operations|
          if uname != ignored_user
            {
              :path          => perm['resource'],
              :user          => uname,
              :operations    => operations,
              :oldoperations => operations,
            }
          end
        end
      end
    end.flatten.compact
  end

  def self.ignored_user
    PuppetX::Inuits::Pulp::PulpAPIv2.getapiconfig['apiuser']
  end
end

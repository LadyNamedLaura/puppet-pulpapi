begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_user).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :name     => 'login',
      :password => 'password',
    }
  end

  def do_create
    api(collection_url, Net::HTTP::Post, {
      :login    => @property_hash[:name],
      :password => @property_hash[:password],
    })
  end
  def do_update
    api(resource_url, Net::HTTP::Put, {
      :delta => {
        :password => @property_hash[:password],
      }
    })
  end

  def collection_url
    'users'
  end

  def resource_url
    "users/#{@property_hash[:name]}"
  end

  def self.rawinstances
    api('users').map do |u|
      if u['login'] != ignored_user
        u["password"] = "****"
        u
      end
    end.compact
  end

  def self.ignored_user
    PuppetX::Inuits::Pulp::APIv2.instance.username
  end
end

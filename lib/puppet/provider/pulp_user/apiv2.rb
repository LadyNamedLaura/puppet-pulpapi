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

  def do_destroy
    api("users/#{@property_hash[:name]}", Net::HTTP::Delete)
  end
  def do_create
    api('users', Net::HTTP::Post, {
      :login    => @property_hash[:name],
      :password => @property_hash[:password],
    })
  end
  def do_update
    api("users/#{@property_hash[:name]}", Net::HTTP::Put, {
      :delta => {
        :password => @property_hash[:password],
      }
    })
  end

  def self.rawinstances
    api('users').map do |u|
      u["password"] = "****"
      if u['login'] == PuppetX::Inuits::Pulp::PulpAPIv2.getapiconfig['apiuser']
        []
      else
        u
      end
    end
  end
end

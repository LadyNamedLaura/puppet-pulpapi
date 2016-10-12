begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_repo).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :name         => 'id',
      :display_name => 'display_name',
      :description  => 'description',
      :notes        => 'notes',
    }
  end

  def do_destroy
    api("repositories/#{@property_hash[:name]}", Net::HTTP::Delete)
  end
  def do_create
    api('repositories', Net::HTTP::Post, {
      :id           => @property_hash[:name],
      :display_name => @property_hash[:display_name],
      :description  => @property_hash[:description],
      :notes        => @property_hash[:notes],
    })
  end
  def do_update
    api("repositories/#{@property_hash[:name]}", Net::HTTP::Put, {
      :delta => {
        :display_name => @property_hash[:display_name],
        :description  => @property_hash[:description],
        :notes        => @property_hash[:notes],
      }
    })
  end

  def self.rawinstances
    api('repositories')
  end
end

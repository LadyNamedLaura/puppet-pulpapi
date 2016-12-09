begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_importer).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :id        => 'id',
      :repo      => 'repo_id',
      :name      => 'repo_id',
      :type      => 'importer_type_id',
      :oldtype   => 'importer_type_id',
      :config    => 'config',
      :oldconfig => 'config',
    }
  end
  def config_unset(newcfg,oldcfg)
    Hash[oldcfg.map{|k,v| [k,nil] } ].merge(newcfg)
  end
  def do_create
    api("repositories/#{@property_hash[:repo]}/importers", Net::HTTP::Post, {
      :importer_type_id => @property_hash[:type],
      :importer_config  => @property_hash[:config],
    })
  end
  def do_update
    if @property_hash[:type] == @property_hash[:oldtype]
      api("repositories/#{@property_hash[:repo]}/importers/#{@property_hash[:id]}", Net::HTTP::Put, {
        :importer_config => config_unset(@property_hash[:config], @property_hash[:oldconfig]),
      })
    else
      do_destroy
      do_create
    end
  end
  def do_destroy
    api("repositories/#{@property_hash[:repo]}/importers/#{@property_hash[:id]}", Net::HTTP::Delete)
  end

  def self.rawinstances
    api('repositories').map do |repo|
      api("repositories/#{repo['id']}/importers")
    end
  end
end

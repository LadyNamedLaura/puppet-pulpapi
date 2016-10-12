begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_distributor).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :name    => 'id',
      :id      => 'id',
      :repo    => 'repo_id',
      :type    => 'distributor_type_id',
      :oldtype => 'distributor_type_id',
      :config  => 'config',
    }
  end
  def do_create
    api("repositories/#{@property_hash[:repo]}/distributors", Net::HTTP::Post, {
      :distributor_id      => @property_hash[:name],
      :distributor_type_id => @property_hash[:type],
      :distributor_config  => @property_hash[:config],
    })
  end
  def do_destroy
    api("repositories/#{@property_hash[:repo]}/distributors/#{@property_hash[:name]}", Net::HTTP::Delete)
  end
  def do_update
    if @property_hash[:type] == @property_hash[:oldtype]
      api("repositories/#{@property_hash[:repo]}/distributors/#{@property_hash[:name]}", Net::HTTP::Put, {
        :distributor_config => @property_hash[:config],
      })
    else
      do_destroy
      do_create
    end
  end

  def self.rawinstances
    api('repositories').map do |repo|
      api("repositories/#{repo['id']}/distributors")
    end
  end
end

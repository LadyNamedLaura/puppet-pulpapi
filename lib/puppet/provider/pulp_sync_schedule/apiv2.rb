begin
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError => detail
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.type(:pulp_sync_schedule).provide(:apiv2, :parent => PuppetX::Inuits::Pulp::PulpAPIv2) do
  mk_resource_methods
  def self.fieldmap
    {
      :id              => '_id',
      :repo            => 'repo_id',
      :sched           => 'schedule',
      :importer        => 'importerid',
      :enabled         => 'enabled',
      :name            => 'repo_id',
      :override_config => 'override_config'
      :oldconfig       => 'override_config'
    }
  end
  def do_create
    @property_hash[:importer] = api("repositories/#{@property_hash[:repo]}/importers")[0]['id']
    api("repositories/#{@property_hash[:repo]}/importers/#{@property_hash[:importer]}/schedules/sync", Net::HTTP::Post, {
      :schedule => @property_hash[:sched],
      :enabled  => @property_hash[:enabled],
      :override_config => config_unset(@property_hash[:override_config], @property_hash[:oldconfig]),
    })
  end
  def do_destroy
    api("repositories/#{@property_hash[:repo]}/importers/#{@property_hash[:importer]}/schedules/sync/#{@property_hash[:id]}", Net::HTTP::Delete)
  end

  def self.rawinstances
    api('repositories').map do |repo|
      api("repositories/#{repo['id']}/importers").map do |importer|
        api("repositories/#{repo['id']}/importers/#{importer['id']}/schedules/sync").map do |sync|
          sync['repo_id'] = repo['id']
          sync['importerid'] = importer['id']
          sync['name'] = "#{sync['repo_id']}::#{sync['schedule']}"
          sync
        end
      end
    end
  end
end

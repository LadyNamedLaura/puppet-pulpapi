require "net/http"
begin
  require 'puppet_x/inuits/pulp/apiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + 'apiv2'
end

module PuppetX
  module Inuits
    module Pulp
    end
  end
end
class PuppetX::Inuits::Pulp::PulpAPIv2 < Puppet::Provider

  # we want to always initialise property_hash
  def initialize(resource = nil)
    if resource.is_a?(Hash)
      @property_hash = resource
    elsif resource
      @resource = resource
      @property_hash = Hash[resource]
    else
      @property_hash = {}
    end
  end

  @@apicache = {}

  def api(endpoint, method=Net::HTTP::Get, data=nil)
    self.class.api(endpoint, method, data)
  end

  def self.api(endpoint, method=Net::HTTP::Get, data=nil)
    use_cache = method == Net::HTTP::Get

    if (use_cache && @@apicache.has_key?(endpoint))
      return @@apicache[endpoint]
    end

    client = PuppetX::Inuits::Pulp::APIv2.instance
    res = client.request(endpoint, method, data)
    @@apicache[endpoint] = res if use_cache
    res
  end

  def create
    @property_hash = Hash[@resource]
    @property_hash[:exists] = false
  end

  def destroy
    if @property_hash[:exists]
      do_destroy
    end
    @property_hash.clear
  end

  def do_update
    do_destroy
    do_create
  end

  def do_destroy
    api(resource_url, Net::HTTP::Delete)
  end

  def exists?
    !(@property_hash[:ensure] == :absent || @property_hash.empty?)
  end

  def config_unset(newcfg,oldcfg)
    unless oldcfg
      return newcfg
    end
    Hash[oldcfg.map{|k,v| [k,nil] } ].merge(newcfg) do |k,o,n|
      if n.is_a?(Hash)
        config_unset(n,oldcfg[k])
      else
        n
      end
    end
  end

  def flush
    return if @property_hash.empty?
    if @property_hash[:ensure] == :absent
      do_destroy
    elsif @property_hash[:exists]
      do_update
    else
      do_create
    end
  end

  @instancecache = false
  def self.instances
    unless @instancecache
      @instancecache = self.rawinstances.map do |instance|
        propertyhash = fieldmap.merge(fieldmap) do |k,v|
          if v.respond_to?('map')
            v.map { |e| instance[e] }.join('::')
          else
            instance[v]
          end
        end
        propertyhash[:exists] = true
        new(propertyhash)
      end
    end
    @instancecache
  end

  def self.prefetch(resources)
    res = resources.values.first
    catalog = res.catalog
    klass   = res.class
    required_resources = catalog.resources.find_all do |e|
      e.class.to_s == klass.to_s
    end

    required_res = Hash[required_resources.map(&:uniqueness_key).zip(required_resources)]
    namevars_ordered = resource_type.key_attributes.map(&:to_s).sort

    existings = instances
    required_res.each do |res_key, resource|
      provider = existings.find do |existing|
        res_key == namevars_ordered.map { |namevar| existing.send(namevar) }
      end
      resource.provider = provider if provider
    end
  end
end

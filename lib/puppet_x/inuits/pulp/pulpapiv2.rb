require "openssl"
require "net/http"
require "uri"
require 'json'

module PuppetX
  module Inuits
    module Pulp
    end
  end
end
class PuppetX::Inuits::Pulp::PulpAPIv2 < Puppet::Provider
  @@apicache = {}
  def api(endpoint, method=Net::HTTP::Get, data=nil)
    self.class.api(endpoint, method, data)
  end
  def self.api(endpoint, method=Net::HTTP::Get, data=nil)

    http= Net::HTTP.new("localhost",443)
    http.use_ssl=true
    http.verify_mode=OpenSSL::SSL::VERIFY_NONE

    if (method == Net::HTTP::Get && @@apicache.has_key?(endpoint))
      return @@apicache[endpoint]
    end
    request = method.new("/pulp/api/v2/#{endpoint}/",'Content-Type' => 'application/json')
    request.basic_auth("admin","admin")
    if data
      request.body = JSON.generate(data)
    end
    response = http.request(request)
    if response.body == 'null'
      res = nil
    else
      res = JSON.parse(response.body)
    end
    raise(Puppet::Error, "#{response.to_s}\n#{JSON.pretty_generate(res)}") if response.code.to_i >= 400
    @@apicache[endpoint] = res if method == Net::HTTP::Get
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

  def exists?
    !(@property_hash[:ensure] == :absent || @property_hash.empty?)
  end

  def flush
    return if @property_hash.empty?
    if @property_hash[:exists]
      do_update
    else
      do_create
    end
  end

  @instancecache = false
  def self.instances
    unless @instancecache
      @instancecache = self.rawinstances.flatten.map do |instance|
        propertyhash = fieldmap.merge(fieldmap) {|k,v| instance[v]}
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

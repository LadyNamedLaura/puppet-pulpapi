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

class PuppetX::Inuits::Pulp::APIv2
  @@instance = false
  def self.instance
    unless @@instance
      config = JSON.parse(File.read(config_filename))
      @@instance = APIv2.initialize(config['apiurl'], config['apiuser'], config['apipass'], config['verify_ssl'])
    end

    @@instance
  end

  def self.config_filename
    File.join(Puppet.settings[:vardir], "pulpapi.json")
  end

  def initialize(apiurl, username, password, verify_ssl)
    @uri = URI.parse(apiurl)
    # TODO: extract username/password from uri?
    @username = username
    @password = password
    @verify_ssl = verify_ssl
  end

  def get_request(endpoint, method)
    method.new("#{@uri.path}/#{endpoint}/", 'Content-Type' => 'application/json')
  end

  def request(endpoint, method=Net::HTTP::Get, data=nil)
    request = get_request(endpoint, method)
    request.basic_auth(@username, @password)
    request.body = JSON.generate(data) if data
    response = connection.request(request)

    res = JSON.parse(response.body)
    raise(Puppet::Error, "#{response.to_s}\n#{JSON.pretty_generate(res)}") if response.code.to_i >= 400
    res
  end

  def connection
    unless @connection
      @connection = Net::HTTP.new(@uri.host, @uri.port)
      @connection.use_ssl = @uri.scheme == 'https'

      if @verify_ssl.is_a?(String)
        @connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @connection.ca_file = @verify_ssl
      elsif @verify_ssl
        @connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    @connection
  end
end

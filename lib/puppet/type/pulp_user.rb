begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/pulpapiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/pulpapiv2'
end

Puppet::Type.newtype(:pulp_user) do
  ensurable do
    newvalues :present, :absent
    defaultto :present
  end

  newparam(:name) do
    isnamevar
  end
  newproperty(:password) do
    def insync?(is)
      begin
        config = PuppetX::Inuits::Pulp::PulpAPIv2.getapiconfig
        uri = URI.parse(config["apiurl"])
        http=Net::HTTP.new(uri.host,uri.port)
        http.use_ssl=true if uri.scheme == "https"
        http.verify_mode=OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new("#{uri.path}/actions/login/",'Content-Type' => 'application/json')
        request.basic_auth(self.resource[:name],should)
        response = http.request(request)
        return response.code.to_i == 200
      rescue
        return false
      end
    end
  end
end

begin
  require 'puppet_x/inuits/pulp/type'
  require 'puppet_x/inuits/pulp/apiv2'
rescue LoadError
  require 'pathname'
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../' + 'puppet_x/inuits/pulp/type'
  require module_base + '../../' + 'puppet_x/inuits/pulp/apiv2'
end

Puppet::Type.newtype(:pulp_user) do
  ensurable do
    newvalues :present, :absent
    defaultto :present
  end

  newparam(:name) do
    desc "The users' login"
    isnamevar
  end

  newproperty(:password) do
    desc "The users' password"

    def insync?(is)
      begin
        api = PuppetX::Inuits::Pulp::APIv2.instance
        request = api.get_request('actions/login', Net::HTTP::Post)
        request.basic_auth(self.resource[:name], should)
        response = api.connection.request(request)
        return response.code.to_i == 200
      rescue
        return false
      end
    end
  end
end

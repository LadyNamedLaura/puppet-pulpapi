require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install puppet
    run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

    # Install the module and its dependencies. We also use katello-pulp
    install_module
    install_module_dependencies
    install_module_from_forge('katello-pulp', '>= 0')

    hosts.each do |host|
      if fact_on(host, 'osfamily') == 'RedHat'
        # don't delete downloaded rpm for use with BEAKER_provision=no +
        # BEAKER_destroy=no
        on host, 'sed -i "s/keepcache=.*/keepcache=1/" /etc/yum.conf'
        # refresh check if cache needs refresh on next yum command
        on host, 'yum clean expire-cache'
        # We always need EPEL
        on host, puppet('resource', 'package', 'epel-release', 'ensure=installed')
      end
    end

    install_pulp = <<-EOS
    yumrepo { 'pulp-2-stable':
      baseurl  => 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/$releasever/$basearch/',
      descr    => 'Pulp 2 Production Releases',
      enabled  => true,
      gpgcheck => true,
      gpgkey   => 'https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-2',
    } ->
    class { '::pulp':
      default_login    => 'admin',
      default_password => 'admin',
    }
    EOS
    apply_manifest_on(hosts, install_pulp, catch_failures: true)
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end

shared_examples 'the example' do |name|
  let(:pp) do
    path = File.join(File.dirname(File.dirname(__FILE__)), 'examples', name)
    File.read(path)
  end

  include_examples 'a idempotent resource'
end

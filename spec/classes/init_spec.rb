require 'spec_helper'

describe 'pulpapi' do
  let :facts do
    {
      :fqdn          => 'foo.example.com',
      :puppet_vardir => '/var/lib/puppet',
    }
  end

  context 'default parameters' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_pulpapi__yum_repo('__empty__') }
    it do
      is_expected.to contain_file('/var/lib/puppet/pulpapi.json')
        .with_content(%r{"apiurl": "https://foo\.example\.com/pulp/api/v2/"})
        .with_content(%r{"httpurl": "http://foo\.example\.com/pulp/repos/"})
        .with_content(%r{"apiuser": "admin"})
        .with_content(%r{"apipass": "admin"})
    end
  end

  context 'with overrides' do
    let :params do
      {
        :mirrors => {'centos-7-x86_64' => 'http://mirror.centos.org/centos/7/x86_64'},
        :users   => {'john' => {'password' => 'secret'}},
      }

    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_pulpapi__yum_repo('__empty__') }

    it do
      is_expected.to contain_pulpapi__yum_mirror_wrapper('centos-7-x86_64')
        .with_mirrorhash({'centos-7-x86_64' => 'http://mirror.centos.org/centos/7/x86_64'})
    end

    it { is_expected.to contain_pulp_user('john').with_password('secret') }
  end
end

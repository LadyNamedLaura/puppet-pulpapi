require 'spec_helper'

describe 'pulpapi' do
  let :facts do
    {:pulp_apiconfig_path => '/tmp/pulpapi.json'}
  end

  context 'default parameters' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_pulpapi__yum_repo('__empty__') }
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

require 'spec_helper_acceptance'

describe 'User management' do
  include_examples 'the example', 'users.pp'

  let(:purge_repos) do
    <<-EOS
    class { '::pulpapi': }
    EOS
  end

  it 'purges repos' do
    apply_manifest(purge_repos, catch_failures: true)
  end
end

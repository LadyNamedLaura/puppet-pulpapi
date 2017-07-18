require 'spec_helper'

describe Puppet::Type.type(:pulp_importer) do
  describe 'namevar' do
    it 'has repo and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :name])
    end
  end

  it_behaves_like 'an ensurable type'

  describe 'autorequiring' do
    repo = Puppet::Type.type(:pulp_repo).new(:name => 'repo')
    resource = described_class.new(:name => 'test', :repo => 'repo')
    it_behaves_like 'an autorequiring resource', resource, repo
  end
end

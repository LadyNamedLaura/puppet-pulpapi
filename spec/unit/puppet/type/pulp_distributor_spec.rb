require 'spec_helper'

describe Puppet::Type.type(:pulp_distributor) do
  describe 'namevar' do
    it 'has repo, id and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :id, :name])
    end
  end

  it_behaves_like 'an ensurable type'

  ['repo', 'id', 'type', 'config'].each do |param|
    it_behaves_like 'a parameter', param
  end

  it_behaves_like 'a boolean parameter', 'auto_publish'

  describe 'autorequiring' do
    repo = Puppet::Type.type(:pulp_repo).new(:name => 'repo')
    resource = described_class.new(:name => 'test', :repo => 'repo')
    it_behaves_like 'an autorequiring resource', resource, repo
  end
end

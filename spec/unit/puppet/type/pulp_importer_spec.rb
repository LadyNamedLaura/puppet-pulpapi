require 'spec_helper'

describe Puppet::Type.type(:pulp_importer) do
  describe 'namevar' do
    it 'has repo as its namevar' do
      expect(described_class.key_attributes).to eq([:repo])
    end
  end

  it_behaves_like 'an ensurable type'

  ['repo', 'type', 'config'].each do |param|
    it_behaves_like 'a parameter', param
  end

  describe 'autorequiring' do
    repo = Puppet::Type.type(:pulp_repo).new(:name => 'repo')
    resource = described_class.new(:name => 'test', :repo => 'repo')
    it_behaves_like 'an autorequiring resource', resource, repo
  end
end

require 'spec_helper'

describe Puppet::Type.type(:pulp_importer) do
  describe 'namevar' do
    it 'has repo and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :name])
    end
  end

  it_behaves_like 'an ensurable type'
end

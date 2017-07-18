require 'spec_helper'

describe Puppet::Type.type(:pulp_distributor) do
  describe 'namevar' do
    it 'has repo, id and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :id, :name])
    end
  end

  it_behaves_like 'an ensurable type'
end

require 'spec_helper'

describe Puppet::Type.type(:pulp_permission) do
  describe 'namevar' do
    it 'has user, path and name as its namevars' do
      expect(described_class.key_attributes).to eq([:user, :path, :name])
    end
  end

  it_behaves_like 'an ensurable type'
end

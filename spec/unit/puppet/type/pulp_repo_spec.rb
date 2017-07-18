require 'spec_helper'

describe Puppet::Type.type(:pulp_repo) do
  describe 'namevar' do
    it 'has name as its namevar' do
      expect(described_class.key_attributes).to eq([:name])
    end
  end

  it_behaves_like 'an ensurable type'

  ['display_name', 'description', 'notes'].each do |param|
    it_behaves_like 'a parameter', param
  end
end

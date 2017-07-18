require 'spec_helper'

describe Puppet::Type.type(:pulp_sync_schedule) do
  describe 'namevar' do
    it 'has repo, sched and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :sched, :name])
    end
  end

  it_behaves_like 'an ensurable type'
end

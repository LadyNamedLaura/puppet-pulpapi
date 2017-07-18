require 'spec_helper'

describe Puppet::Type.type(:pulp_sync_schedule) do
  describe 'namevar' do
    it 'has repo, sched and name as its namevars' do
      expect(described_class.key_attributes).to eq([:repo, :sched, :name])
    end
  end

  it_behaves_like 'an ensurable type'

  [:pulp_repo, :pulp_importer].each do |type|
    describe "autorequire #{type}" do
      requirement = Puppet::Type.type(type).new(:name => 'bunnies')
      resource = described_class.new(:name => 'test', :repo => 'bunnies')
      it_behaves_like 'an autorequiring resource', resource, requirement
    end
  end
end

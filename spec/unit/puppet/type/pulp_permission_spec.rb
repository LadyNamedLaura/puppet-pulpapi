require 'spec_helper'

describe Puppet::Type.type(:pulp_permission) do
  describe 'namevar' do
    it 'has user, path and name as its namevars' do
      expect(described_class.key_attributes).to eq([:user, :path, :name])
    end
  end

  it_behaves_like 'an ensurable type'

  ['user', 'path'].each do |param|
    it_behaves_like 'a parameter', param
  end

  describe 'operations' do
    values = ['CREATE', 'READ', 'UPDATE', 'DELETE', 'EXECUTE']

    values.each do |value|
      it "accepts #{value}" do
        expect { described_class.new(name: 'test', operations: value) }.not_to raise_error
      end
    end

    it "accepts #{values}" do
      expect { described_class.new(name: 'test', operations: values) }.not_to raise_error
    end

    it "rejects unknown values" do
      expect { described_class.new(name: 'test', operations: 'create') }.to raise_error(Puppet::Error)
    end

    it "ignores order" do
      instance = described_class.new(name: 'test', operations: values)
      is = values.reverse
      expect(instance.property('operations').insync?(is)).to be true
    end
  end

  describe 'autorequiring' do
    user = Puppet::Type.type(:pulp_user).new(:name => 'user')
    resource = described_class.new(:name => 'test', :user => 'user')
    it_behaves_like 'an autorequiring resource', resource, user
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'

shared_examples 'an ensurable type' do |param|
  param ||= 'ensure'
  describe param do
    %i[present absent].each do |value|
      it "accepts #{value} as a value" do
        expect { described_class.new(name: 'test', param => value) }.not_to raise_error
      end
    end

    it 'rejects other values' do
      expect { described_class.new(name: 'test', param => 'foo') }.to raise_error(Puppet::Error)
    end

    it 'defaults to present' do
      expect(described_class.new(name: 'test').should(param)).to eq(:present)
    end
  end
end

shared_examples 'a parameter' do |param|
  describe param do
    it "accepts test as a value" do
      expect { described_class.new(name: 'test', param => 'test') }.not_to raise_error
    end
  end
end

shared_examples 'an autorequiring resource' do |resource, requirement|
  it do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource

    expect(resource.autorequire.size).to eq(0)

    catalog.add_resource requirement

    req = resource.autorequire
    expect(req.size).to eq(1)
    expect(req[0].target).to eq(resource)
    expect(req[0].source).to eq(requirement)
  end
end

shared_examples 'a boolean parameter' do |param|
  describe param do
    [true, false, 'true', 'false'].each do |value|
      it "accepts #{value} as a value" do
        expect { described_class.new(name: 'test', param => value) }.not_to raise_error
      end
    end

    it 'rejects other values' do
      expect { described_class.new(name: 'test', param => 'foo') }.to raise_error(Puppet::Error)
    end
  end
end

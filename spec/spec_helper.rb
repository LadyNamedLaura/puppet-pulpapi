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

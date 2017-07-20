require 'spec_helper'

describe Puppet::Type.type(:pulp_importer).provider(:apiv2) do
  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end

    # TODO: webmock the API and verify
  end

  describe 'prefetch' do
    it 'should have a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  describe 'do_destroy' do
    it do
      instance = get_instance

      instance.expects(:api).with('repositories/repo/importers/imp', Net::HTTP::Delete).returns(true)

      expect(instance.do_destroy).to be true
    end
  end

  describe 'do_create' do
    it do
      instance = get_instance

      data = {
        :importer_type_id => 'rpm',
        :importer_config => {},
      }
      instance.expects(:api).with('repositories/repo/importers', Net::HTTP::Post, data).returns(true)

      expect(instance.do_create).to be true
    end
  end

  describe 'do_update' do
    it 'should use put with unchanged type' do
      data = {
        :importer_config => {},
      }
      described_class.expects(:api).with('repositories/repo/importers/imp', Net::HTTP::Put, data).returns(true)

      instance = get_instance(:type => 'rpm', :oldtype => 'rpm')
      expect(instance.do_update).to be true
    end

    it 'should recreate when type changes' do
      instance = get_instance(:type => 'puppet', :oldtype => 'rpm')
      instance.expects(:do_destroy)
      instance.expects(:do_create)
      expect(instance.do_update).to be nil
    end
  end

  describe 'rawinstances' do
    it 'should handle no importers' do
      described_class.expects(:api).with('repositories').returns([])
      expect(described_class.rawinstances).to eq []
    end

    it 'should handle repositories with importers' do
      described_class.expects(:api).with('repositories').returns([{'id' => 'first'}])
      described_class.expects(:api).with('repositories/first/importers').returns({})
      expect(described_class.rawinstances).to eq [{}]
    end
  end

  private

  def get_instance(params={})
    defaults = {
      :id => 'imp',
      :repo => 'repo',
      :name => 'imp',
      :type => 'rpm',
      :oldtype => 'rpm',
      :config => {},
      :oldconfig => {},
    }
    defaults.update(params)

    described_class.new(defaults)
  end
end

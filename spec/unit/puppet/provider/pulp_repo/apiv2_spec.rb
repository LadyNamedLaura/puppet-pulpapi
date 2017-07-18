require 'spec_helper'

describe Puppet::Type.type(:pulp_repo).provider(:apiv2) do
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
      described_class.expects(:api).with('repositories/test', Net::HTTP::Delete, nil).returns(true)

      expect(described_class.new(:name => 'test').do_destroy).to be true
    end
  end

  describe 'do_create' do
    it do
      data = {
        :id => 'test',
        :display_name => 'display name',
        :description => 'description',
        :notes => {},
      }
      described_class.expects(:api).with('repositories', Net::HTTP::Post, data).returns(true)

      instance = described_class.new(
        :name => 'test',
        :display_name => 'display name',
        :description => 'description',
        :notes => {},
      )
      expect(instance.do_create).to be true
    end
  end

  describe 'do_update' do
    it do
      data = {
        :delta => {
          :display_name => 'display name',
          :description => 'description',
          :notes => {},
        },
      }
      described_class.expects(:api).with('repositories/test', Net::HTTP::Put, data).returns(true)

      instance = described_class.new(
        :name => 'test',
        :display_name => 'display name',
        :description => 'description',
        :notes => {},
      )
      expect(instance.do_update).to be true
    end
  end

  describe 'rawinstances' do
    it do
      described_class.expects(:api).with('repositories').returns([])

      expect(described_class.rawinstances).to eq []
    end
  end
end

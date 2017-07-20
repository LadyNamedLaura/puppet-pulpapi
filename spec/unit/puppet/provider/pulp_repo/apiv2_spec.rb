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
      instance = get_instance
      instance.expects(:api).with('repositories/test', Net::HTTP::Delete).returns(true)
      expect(instance.do_destroy).to be true
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

      instance = get_instance
      instance.expects(:api).with('repositories', Net::HTTP::Post, data).returns(true)
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

      instance = get_instance
      instance.expects(:api).with('repositories/test', Net::HTTP::Put, data).returns(true)
      expect(instance.do_update).to be true
    end
  end

  describe 'rawinstances' do
    it do
      described_class.expects(:api).with('repositories').returns([])
      expect(described_class.rawinstances).to eq []
    end
  end

  private

  def get_instance(params={})
    defaults = {
      :name => 'test',
      :display_name => 'display name',
      :description => 'description',
      :notes => {},
    }
    defaults.update(params)

    described_class.new(defaults)
  end
end

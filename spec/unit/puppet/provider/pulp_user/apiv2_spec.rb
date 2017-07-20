require 'spec_helper'

describe Puppet::Type.type(:pulp_user).provider(:apiv2) do
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
      instance.expects(:api).with('users/username', Net::HTTP::Delete).returns(true)
      expect(instance.do_destroy).to be true
    end
  end

  describe 'do_create' do
    it do
      data = {
        :login => 'username',
        :password => 'secret',
      }

      instance = get_instance
      instance.expects(:api).with('users', Net::HTTP::Post, data).returns(true)
      expect(instance.do_create).to be true
    end
  end

  describe 'do_update' do
    it do
      data = {
        :delta => {
          :password => 'secret',
        },
      }

      instance = get_instance
      instance.expects(:api).with('users/username', Net::HTTP::Put, data).returns(true)
      expect(instance.do_update).to be true
    end
  end

  describe 'rawinstances' do
    it 'should handle no users' do
      users = []
      expected = []

      described_class.expects(:api).with('users').returns(users)
      expect(described_class.rawinstances).to eq expected
    end

    it 'should handle users' do
      users = [
        {'login' => 'admin', 'password' => 'secret'},
        {'login' => 'username', 'password' => 'secret'},
      ]
      expected = [
        {'login' => 'username', 'password' => '****'},
      ]

      described_class.stubs(:ignored_user).returns('admin')
      described_class.expects(:api).with('users').returns(users)
      expect(described_class.rawinstances).to eq expected
    end
  end

  private

  def get_instance(params={})
    defaults = {
      :name => 'username',
      :password => 'secret',
    }
    defaults.update(params)

    described_class.new(defaults)
  end
end

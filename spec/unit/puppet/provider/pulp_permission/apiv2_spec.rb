require 'spec_helper'

describe Puppet::Type.type(:pulp_permission).provider(:apiv2) do
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

      data = {
        :login => 'username',
        :resource => '/repositories/repository',
        :operations => ['CREATE'],
      }
      instance.expects(:api).with('permissions/actions/revoke_from_user', Net::HTTP::Post, data).returns(true)

      expect(instance.do_destroy).to be true
    end
  end

  describe 'do_create' do
    it do
      instance = get_instance

      data = {
        :login => 'username',
        :resource => '/repositories/repository',
        :operations => ['CREATE'],
      }
      instance.expects(:api).with('permissions/actions/grant_to_user', Net::HTTP::Post, data).returns(true)

      expect(instance.do_create).to be true
    end
  end

  describe 'do_update' do
    it do
      instance = get_instance
      instance.expects(:do_destroy)
      instance.expects(:do_create)
      expect(instance.do_update).to be nil
    end
  end

  describe 'rawinstances' do
    it 'should handle no permissions' do
      permissions = []
      expected = []
      described_class.expects(:api).with('permissions').returns(permissions)
      expect(described_class.rawinstances).to eq expected
    end

    it 'should handle permissions' do
      permissions = [
        {
          'resource' => '/repositories/repository',
          'users' => {
            'username' => ['READ'],
            'admin' => ['READ'],
          },
        },
        {
          'resource' => '/v2/actions/login/',
          'users' => {
            'username' => ['EXECUTE'],
          },
        },
      ]
      expected = [
        {
          :path => '/repositories/repository',
          :user => 'username',
          :operations => ['READ'],
          :oldoperations => ['READ'],
        },
      ]

      described_class.stubs(:ignored_user).returns('admin')
      described_class.expects(:api).with('permissions').returns(permissions)
      expect(described_class.rawinstances).to eq expected
    end
  end

  private

  def get_instance(params={})
    defaults = {
      :name => ['username', 'repository'],
      :path => '/repositories/repository',
      :user => 'username',
      :operations => ['CREATE'],
      :oldoperations => ['CREATE'],
    }
    defaults.update(params)

    described_class.new(defaults)
  end
end

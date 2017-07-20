require 'spec_helper'

describe Puppet::Type.type(:pulp_sync_schedule).provider(:apiv2) do
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
      instance.expects(:api).with('repositories/repo/importers/1/schedules/sync/1', Net::HTTP::Delete).returns(true)
      expect(instance.do_destroy).to be true
    end
  end

  describe 'do_create' do
    it do
      data = {
        :schedule => 'P1DT',
        :enabled => true,
        :override_config => {},
      }

      instance = get_instance
      instance.expects(:api).with('repositories/repo/importers').returns([{'id' => 1}])
      instance.expects(:api).with('repositories/repo/importers/1/schedules/sync', Net::HTTP::Post, data).returns(true)
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
    it 'should handle no repositories' do
      repositories = []
      expected = []

      described_class.expects(:api).with('repositories').returns(repositories)
      expect(described_class.rawinstances).to eq expected
    end

    it 'should handle repositories without importers' do
      repositories = [{'id' => 'repo'}]
      importers = []
      expected = []

      described_class.expects(:api).with('repositories').returns(repositories)
      described_class.expects(:api).with('repositories/repo/importers').returns(importers)
      expect(described_class.rawinstances).to eq expected
    end

    it 'should handle repositories with importer without schedule' do
      repositories = [{'id' => 'repo'}]
      importers = [{'id' => 1}]
      schedules = []
      expected = []

      described_class.expects(:api).with('repositories').returns(repositories)
      described_class.expects(:api).with('repositories/repo/importers').returns(importers)
      described_class.expects(:api).with('repositories/repo/importers/1/schedules/sync').returns(schedules)
      expect(described_class.rawinstances).to eq expected
    end

    it 'should handle repositories with importer with schedule' do
      repositories = [{'id' => 'repo'}]
      importers = [{'id' => 1}]
      schedules = [{'id' => 2, 'schedule' => 'P1DT', 'kwargs' => {'overrides' => {}}}]
      expected = [
        {
          'id' => 2,
          'schedule' => 'P1DT',
          'kwargs' => {'overrides' => {}},
          'repo_id' => 'repo',
          'importerid' => 1,
          'name' => 'repo::P1DT',
          'override_config' => {},
        }
      ]

      described_class.expects(:api).with('repositories').returns(repositories)
      described_class.expects(:api).with('repositories/repo/importers').returns(importers)
      described_class.expects(:api).with('repositories/repo/importers/1/schedules/sync').returns(schedules)
      expect(described_class.rawinstances).to eq expected
    end
  end

  private

  def get_instance(params={})
    defaults = {
      :id => 1,
      :sched => 'P1DT',
      :name => 'repo::sched',
      :repo => 'repo',
      :importer => 1,
      :enabled => true,
      :override_config => {},
      :oldconfig => {},
    }
    defaults.update(params)

    described_class.new(defaults)
  end
end

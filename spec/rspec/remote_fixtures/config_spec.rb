# frozen_string_literal: true

require 'byebug'
RSpec.describe RSpec::RemoteFixtures::Config do
  let(:conf) { described_class }

  before do
    described_class.reset!
  end

  it 'has the correct defaults', :aggregate_failures do
    load Object.const_source_location(described_class.name)[0]
    expect(conf.manifest_path).to eq('spec/fixtures.json')
    expect(conf.fixture_path).to eq(Pathname.new('spec/fixtures/'))
    expect(conf.backend).to eq(RSpec::RemoteFixtures::Backend::S3Backend)
    expect(conf.backend_path).to eq(nil)
    expect(conf.check_remote_fixture_digest).to eq(:download)
  end

  it 'allows setting values', :aggregate_failures do
    conf.manifest_path = 'foo/bar.json'
    conf.fixture_path = 'foo/fixtures'
    conf.backend = RSpec::RemoteFixtures::Backend
    conf.backend_path = 's3://foo/bar/baz'
    conf.check_remote_fixture_digest = :never

    expect(conf.manifest_path).to eq('foo/bar.json')
    expect(conf.fixture_path).to eq(Pathname.new('foo/fixtures'))
    expect(conf.backend).to eq(RSpec::RemoteFixtures::Backend)
    expect(conf.backend_path).to eq('s3://foo/bar/baz')
    expect(conf.check_remote_fixture_digest).to eq(:never)
  end

  describe '#fixture_path=' do
    it 'handles passed Pathname' do
      inst = Pathname.new('foo/fixtures')
      conf.fixture_path = inst
      expect(conf.fixture_path).to equal(inst)
    end
  end
end

# frozen_string_literal: true

require_relative 'remote_fixtures/version'
require_relative 'remote_fixtures/manifest'
require_relative 'remote_fixtures/example_group'
require_relative 'remote_fixtures/backend'
require_relative 'remote_fixtures/config'

# Why would I ever want to use this gem?
# =========================================
# This gem lets you stop committing large fixture files, without having to worry about git-lfs.
# Furthermore, a great many applications use docker images to run in production and CI. If you have
# hundreds of MB worth of fixture files, these files are first downloaded to wherever the image is being built,
# then uploaded, over the network, likely to many different CI workers and production instances.
#
# Once the files are there, it's likely only a small proportion of these workers actually *need* any particular file.
#
# Thus, rspec-remote-fixtures: A gem that sticks your rspec fixtures in S3, and downloads them transparently

module RSpec
  # An on-demand-fixture-downloader for RSpec
  module RemoteFixtures
    class Error < StandardError; end

    def self.backend_inst
      @backend_inst ||= Config.backend.new
    end

    def self.ensure_file(relative_path)
      full_path = full_path_from_relative(relative_path)
      entry = Manifest.entry_for(relative_path)
      log_not_found(relative_path) unless entry

      verify_checksum(entry, full_path) if Config.check_remote_fixture_digest == :always
      file_present = File.exist?(full_path)

      retrieve_entry(entry, full_path) unless file_present
      maybe_verify(entry, full_path, file_present)

      full_path
    end

    def self.full_path_from_relative(relative_path)
      Pathname.new(Config.fixture_path).join(relative_path)
    end

    def self.retrieve_entry(entry, dest)
      raise Error, "Attempted to retrieve #{dest} but it wasn't present in the manifest" unless entry

      FileUtils.mkdir_p(dest.dirname)
      backend_inst.download(entry['remote_path'], dest)
    end

    def self.maybe_verify(entry, path, file_present)
      config_val = Config.check_remote_fixture_digest
      return if config_val == :never
      return if config_val == :download && file_present

      raise Error, "Unable to verify digest for #{path} - entry not found" unless entry

      digest = Manifest.compute_digest(path)
      raise Error, "Digest for #{path} did not match manifest entry, aborting!" unless digest == entry['digest']
    end

    def self.setup_examples!
      return if @setup_done

      @setup_done = true
      RSpec.configuration.prepend(ExampleGroup)
    end

    def self.log_not_found(relative_path)
      msg = "Warning: fixture #{relative_path} not found in manifest, this spec may fail elsewhere!"
      RSpec.configuration.reporter.message(msg)
    end

    def self.upload(relative_path, digest)
      full_path = full_path_from_relative(relative_path)
      backend_inst.upload(full_path, digest)
    end

    def self.setup_rspec!
      RSpec.configuration.fixture_path = Config.fixture_path if RSpec.configuration.respond_to?(:fixture_path=)
      if RSpec.configuration.respond_to?(:file_fixture_path=)
        RSpec.configuration.file_fixture_path = Config.fixture_path
      end

      RSpec::Core::World.prepend(World)
      FactoryBot::SyntaxRunner.include(ExampleGroup) if defined? FactoryBot::SyntaxRunner
    end

    # RSpec uses this for global data that's not configuration
    module World
      def ordered_example_groups
        RSpec::RemoteFixtures.setup_examples!
        super
      end
    end
  end
end

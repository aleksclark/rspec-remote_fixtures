# frozen_string_literal: true

require_relative '../../rspec/remote_fixtures'

module Rspec
  module Generators
    # @private
    class FixtureManifestGenerator < ::Rails::Generators::Base
      desc <<~DESC
        Description:
            Generate a fixture manifest for rspec/remote_fixtures.
      DESC
      class_option :files, type: :array, default: [], optional: true
      class_option :force, type: :boolean, default: false, optional: true

      def generate_manifest
        create_file config.manifest_path, '{}' if !File.exist?(config.manifest_path) || options.force

        add_files

        say "Persisting manifest to #{config.manifest_path}"
        RSpec::RemoteFixtures::Manifest.persist_manifest!
      end

      private

      def add_files
        if options.files.any?
          options.files.each { |file| add_file(file) }
        else
          say "#{fixture_files.count} fixtures found..."
          fixture_files.each { |path| add_file(path) }
        end
      end

      def fixture_files
        return @fixture_files if defined? @fixture_files

        @fixture_files = []
        Dir.chdir do
          Dir.glob("#{config.fixture_path}/**/*", File::FNM_DOTMATCH) do |path|
            next if File.directory?(path)

            fixture_files << path
          end
        end

        @fixture_files
      end

      def add_file(path)
        path = Pathname.new(path)
        path = Pathname.new(Dir.pwd).join(path) unless path.absolute?
        path = path.relative_path_from(config.fixture_path)
        say "Adding #{path} to the manifest.."
        RSpec::RemoteFixtures::Manifest.add_fixture!(path)
      end

      def config
        RSpec::RemoteFixtures::Config
      end
    end
  end
end

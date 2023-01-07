# frozen_string_literal: true

require_relative '../../rspec/remote_fixtures'

module Rspec
  module Generators
    # @private
    class FixtureManifestGenerator < ::Rails::Generators::Base
      desc <<~DESC
        Description:
            Generate a fixture manifest for rspec/remote_fixtures
      DESC

      def generate_manifest
        create_file config.manifest_path, '{}'

        say "#{fixture_files.count} fixtures found..."
        fixture_files.each { |path| add_file(path) }

        say "Persisting manifest to #{config.manifest_path}"
        RSpec::RemoteFixtures::Manifest.persist_manifest!
      end

      private

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
        path = Pathname.new(path).relative_path_from(config.fixture_path)
        say "Adding #{path} to the manifest.."
        RSpec::RemoteFixtures::Manifest.add_fixture!(path)
      end

      def config
        RSpec::RemoteFixtures::Config
      end
    end
  end
end

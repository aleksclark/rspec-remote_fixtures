# frozen_string_literal: true

module RSpec
  module RemoteFixtures
    # Hooks into RSpec so that RemoteFixtures is available in examples
    module ExampleGroup
      def remote_fixture_path(path)
        RemoteFixtures.ensure_file(path)
      end

      # need to maintain compatibility with rspec-rails
      # rubocop:disable Style/OptionalBooleanParameter
      def fixture_file_upload(path, mime = nil, binary = false)
        RemoteFixtures.ensure_file(path)
        super(path, mime, binary)
      end
      # rubocop:enable Style/OptionalBooleanParameter
    end
  end
end

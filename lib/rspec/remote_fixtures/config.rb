# frozen_string_literal: true

require 'aws-sdk-s3'
require_relative 'backend'

module RSpec
  module RemoteFixtures
    # Configuration namespace for RemoteFixtures
    #
    # Defaults:
    # `manifest_path`: `spec/fixtures.json`
    # `fixture_path`: `spec/fixtures/`
    # `backend`: `RSpec::RemoteFixtures::Backend::S3Backend`
    # `backend_path`: None, must be configured
    # `check_remote_fixture_path`: ``:download``
    module Config
      def self.manifest_path=(value)
        @manifest_path = value
      end

      def self.manifest_path
        @manifest_path || 'spec/fixtures.json'
      end

      def self.fixture_path=(value)
        value = Pathname.new(value) unless value.is_a? Pathname
        @fixture_path = value
      end

      def self.fixture_path
        @fixture_path ||= Pathname.new('spec/fixtures/')
      end

      def self.backend=(value)
        @backend = value
      end

      def self.backend
        @backend || Backend::S3Backend
      end

      def self.backend_path=(value)
        @backend_path = value
      end

      def self.backend_path
        @backend_path
      end

      def self.s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def self.s3_client=(value)
        @s3_client = value
      end

      def self.check_remote_fixture_digest=(value)
        @check_remote_fixture_digest = value
      end

      def self.check_remote_fixture_digest
        @check_remote_fixture_digest || :download
      end

      def self.reset!
        @backend_path = nil
        @check_remote_fixture_digest = nil
        @fixture_path = nil
        @backend = nil
        @manifest_path = nil
      end
    end
  end
end

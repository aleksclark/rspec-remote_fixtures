# frozen_string_literal: true

require 'open-uri'
require 'active_support'
require 'active_support/core_ext'

module RSpec
  module RemoteFixtures
    # Keep track of fixture files, their digest, and their remote locations
    module Manifest
      # Support accepting a remote path and digest in case upload has already been performed
      def self.add_fixture!(relative_path, remote_path = nil, digest = nil)
        digest ||= compute_digest(relative_path)
        remote_path ||= RemoteFixtures.upload(relative_path, digest)
        manifest[relative_path] = { 'digest' => digest, 'remote_path' => remote_path }
      end

      def self.persist_manifest!
        File.write(manifest_path, manifest.to_json)
      end

      def self.entry_for(relative_path)
        manifest[relative_path]
      end

      def self.manifest
        return @manifest if defined?(@manifest)

        init_manifest! unless File.exist?(manifest_path)
        @manifest = JSON.parse(File.read(manifest_path))
      end

      def self.init_manifest!
        puts "Initializing rspec-remote-fixtures manifest #{manifest_path}"
        File.write(manifest_path, {}.to_json)
      end

      def self.manifest_path
        Config.manifest_path
      end

      def self.compute_digest(path)
        File.open(RemoteFixtures.full_path_from_relative(path), 'rb') { |f| Digest::MD5.hexdigest(f.read) }
      end
    end
  end
end

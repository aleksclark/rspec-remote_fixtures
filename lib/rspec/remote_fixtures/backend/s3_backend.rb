# frozen_string_literal: true

require 'aws-sdk-s3'
require_relative '../config'

module RSpec
  module RemoteFixtures
    module Backend
      # An S3 backend for RemoteFixtures
      # Will only re-upload if the local digest doesn't match the remote object's etag
      class S3Backend
        attr_reader :s3_path, :s3_bucket, :s3_prefix, :bucket_name

        def initialize
          @s3_path = RemoteFixtures::Config.backend_path
          raise Error, 'S3 path has not been configured!' unless @s3_path

          components = s3_path.gsub('s3://', '').split('/')
          @bucket_name = components[0]
          @s3_bucket = s3.bucket(bucket_name)
          @s3_prefix = components[1..].join('/')
          super
        end

        def s3
          @s3 ||= Aws::S3::Resource.new
        end

        def upload(path, digest)
          file_name = "#{digest}_#{File.basename(path)}"
          bucket_path = "#{s3_prefix}/#{file_name}"
          obj = s3_bucket.object(bucket_path)
          obj.upload_file(path) unless digest_match?(obj, digest)

          "s3://#{bucket_name}/#{bucket_path}"
        end

        def download(remote_path, local_path)
          report_download(remote_path, local_path)
          if defined? Timecop && Timecop&.frozen? # rubocop:disable Style/SafeNavigation
            Timecop.unfreeze do
              perform_download(remote_path, local_path)
            end
          else
            perform_download(remote_path, local_path)
          end
        end

        private

        def perform_download(remote_path, local_path)
          bucket_path = remote_path.to_s.gsub('s3://', '').split('/')[1..].join('/')
          obj = s3_bucket.object(bucket_path)
          # byebug
          obj.download_file(local_path.to_s)
        end

        def report_download(remote_path, local_path)
          msg = "#{local_path} not present locally, retrieving from #{remote_path}"
          RSpec.configuration.reporter.message(msg)
        end

        def digest_match?(obj, digest)
          digest == JSON.parse(obj.etag)
        rescue StandardError
          false
        end
      end
    end
  end
end

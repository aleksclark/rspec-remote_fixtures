# frozen_string_literal: true

module RSpec
  module RemoteFixtures
    # Storage backends for RemoteFixtures
    module Backend
    end
  end
end

require_relative 'backend/s3_backend'

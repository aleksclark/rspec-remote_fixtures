# frozen_string_literal: true

require_relative 'lib/rspec/remote_fixtures/version'

Gem::Specification.new do |spec|
  spec.name = 'rspec-remote_fixtures'
  spec.version = RSpec::RemoteFixtures::VERSION
  spec.authors = ['Aleks Clark']
  spec.email = ['aleks.clark@gmail.com']

  spec.summary = 'Allow rspec to fetch fixture files on demand'
  spec.description = 'Allow rspec to fetch fixture files on demand.'
  spec.homepage = 'https://github.com/aleksclark/rspec-remote_fixtures'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/aleksclark/rspec-remote_fixtures'
  spec.metadata['changelog_uri'] = 'https://github.com/aleksclark/rspec-remote_fixtures/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6.1'
  spec.add_dependency 'aws-sdk-s3', '~> 1.0'
  spec.add_dependency 'rspec', '~> 3.12'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end

# RSpec::RemoteFixtures

RemoteFixtures is a plugin for RSpec that lets you store test fixture files in s3 to avoid unnecessary overhead.

Why would I ever want to use this gem?
=========================================
This gem lets you stop committing large fixture files, without having to worry about git-lfs.
Furthermore, a great many applications use docker images to run in production and CI. If you have
hundreds of MB worth of fixture files, these files are first downloaded to wherever the image is being built,
then uploaded, over the network, likely to many CI workers and production instances.
Once the files are there, it's likely only a small proportion of these workers actually *need* any particular file.

Thus, rspec-remote-fixtures: A gem that sticks your rspec fixtures in S3, and downloads them transparently


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rspec-remote_fixtures

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rspec-remote_fixtures

You will likely want to add the gem to the `develop` and `test` groups in your application's Gemfile
## Configuration

Create an initializer `rspec_remote_fixtures.rb`:

```ruby
if Rails.env.test? || Rails.env.development?
  RSpec::RemoteFixtures::Config.backend_path = 's3://my-s3-bucket/some-prefix-path/'
  # the following are defaults, only set if you want to override them
  RSpec::RemoteFixtures::Config.manifest_path = 'spec/fixtures.json'
  RSpec::RemoteFixtures::Config.backend = RSpec::RemoteFixtures::Backend::S3Backend
  RSpec::RemoteFixtures::Config.fixture_path = Rails.root.join('spec/fixtures')
  # use to set/override s3 auth if you need different credentials for the above bucket
  RSpec::RemoteFixtures::Config.s3_client = Aws::S3::Client.new 
  
  # When should we validate the digest of a file fixture?
  # always: any time the file is used in a spec
  # download: whenever the file is downloaded to this runner for the first time
  # never: <--
  RSpec::RemoteFixtures::Config.check_remote_fixture_digest = :download
end
```

In your `rails_helper.rb`:

```ruby
require 'rspec/rails'
# Important: we hook into some of the helpers provided by rspec/rails so this must come after requiring it:
RSpec::RemoteFixtures.setup_rspec!
```

After the gem is configured, you will want to generate a manifest of your existing fixtures:
```shell
rails generate rspec:fixture_manifest
```

If the s3 object in question has an `etag` which matches the local digest of the file, the file will not
be re-uploaded.

Future files can be added or updated by calling the generator again with the `--files` parameter:

```shell
rails generate rspec:fixture_manifest --files spec/fixtures/bob.txt
```

Once the manifest has been set up, you can remove the fixture files from version control, and commit the manifest file.

## Usage

There are two main ways to use this tool in your specs:

```ruby
# fixture_file_path returns an absolute Pathname to a fixture located in RSpec::RemoteFixtures::Config.fixture_path
# The following invocation will ensure the file is present, 
# and return Pathname.new('/my/rails/root/spec/fixtures/bob.txt')
# This method is available to FactoryBot factories as well as RSpec examples.
fixture_file_path('bob.txt')

# fixture_file_upload hooks into rspec/rails's method of the same name, 
# downloading the file if not present and then calling super
fixture_file_upload('bob.txt')
```

## Warnings

S3 authentication relies on an accurate date. If you are using Timecop, RemoteFixtures will attempt to unfreeze for the 
while downloading the file, and return, by calling `Timecop.unfreeze` in a block. Other libraries that freeze time may 
cause downloads to fail.

## Design

RSpec::RemoteFixtures creates a manifest JSON file of the following form:
```json
{
  "some/path.txt": {
    "digest": "d8e8fca2dc0f896fd7cb4cb0031ba249",
    "remote_path": "s3://some-bucket/prefix/d8e8fca2dc0f896fd7cb4cb0031ba249_path.txt"
  }
}
```

When `fixture_file_path` is called, the gem checks to see if the file is present on the local filesystem, 
and conditionally verifies the digest of the local copy (see Configuration section). If the file is not present,
it retrieves the file, again potentially verifying the digest.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aleksclark/rspec-remote_fixtures.

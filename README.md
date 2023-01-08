# RSpec::RemoteFixtures

RemoteFixtures is a plugin for RSpec that lets you store test fixture files in s3 to avoid unecessary overhead.

Why would I ever want to use this gem?
=========================================
This gem lets you stop committing large fixture files, without having to worry about git-lfs.
Furthermore, a great many applications use docker images to run in production and CI. If you have
hundreds of MB worth of fixture files, these files are first downloaded to wherever the image is being built,
then uploaded, over the network, likely to many different CI workers and production instances.
Once the files are there, it's likely only a small proportion of these workers actually *need* any particular file.

Thus, rspec-remote-fixtures: A gem that sticks your rspec fixtures in S3, and downloads them transparently


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rspec-remote-fixtures

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rspec-remote-fixtures

## Usage

## Warnings

S3 authentication relies on an accurate date. If you are using Timecop, RemoteFixtures will attempt to unfreeze for the 
while downloading the file, and return, by calling `Timecop.unfreeze` in a block. Other libraries that freeze time may 
cause downloads to fail.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rspec-remote-fixtures.

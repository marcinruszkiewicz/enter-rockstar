# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'enter_rockstar'
require 'enter_rockstar/cli'
require 'pry'
require 'vcr'
require 'fakefs/spec_helpers'

VCR.configure do |config|
  config.configure_rspec_metadata!
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :once
  }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def file_fixture(fixture_name)
  path = Pathname.new(File.join(fixture_name))

  if path.exist?
    path
  else
    msg = "file does not exist: '%s'"
    raise ArgumentError, format(msg, fixture_name)
  end
end

def gunzip(string)
  Zlib::GzipReader.new(StringIO.new(string)).read
end

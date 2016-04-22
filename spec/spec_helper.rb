require 'bundler/setup'
begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
     SimpleCov::Formatter::HTMLFormatter,
     Coveralls::SimpleCov::Formatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError => e
  STDERR.puts "Coverage Skipped: #{e.message}"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sycamore'

SPEC_DIR = File.dirname(__FILE__)
Dir[File.join(SPEC_DIR, 'support/**/*.rb')].each {|f| require f }

RSpec::Matchers.define_negated_matcher :be_different_to, :be

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.example_status_persistence_file_path = './spec/examples.txt'
end

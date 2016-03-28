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
require 'set'

SPEC_DIR = File.dirname(__FILE__)

Dir[File.join(SPEC_DIR, 'scratch/support/**/*.rb')].each {|f| require f }
Dir[File.join(SPEC_DIR, 'support/**/*.rb')].each {|f| require f }

RSpec::Matchers.define_negated_matcher :be_different_to, :be

# TODO: How can we implement this without global variables with RSpec?

$last_number = 0
$last_string = 0
$last_symbol = 0

def number
  $last_number += 1
end
alias another_number number

def last_number
  $last_number
end

def string
  "string#{$last_string += 1}"
end
alias another_string string

def last_string
  $last_string
end

def symbol
  "symbol#{$last_symbol += 1}".to_sym
end
alias another_symbol symbol

def last_symbol
  $last_symbol
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.example_status_persistence_file_path = './spec/examples.txt'
end


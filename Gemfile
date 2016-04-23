source 'https://rubygems.org'

gemspec

group :development do
  gem 'guard-rspec'
  gem 'listen', '< 3.1' # to circumvent the fail for Ruby 2.1 and Rubinius
  gem 'pry'
end

group :test do
  gem 'coveralls', require: false, platform: :mri
end

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "Couldn't find RSpec core Rake task"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
    # t.options = ['--any', '--extra', '--opts'] # optional
    # t.stats_options = ['--list-undoc']         # optional
  end
rescue LoadError
  puts "Couldn't find YARD"
end

namespace :demo do
  API = 'examples/api_readme.rb'
  API_OUT = 'examples/api_readme_out.rb'

  desc "Builds the demo in #{API}"
  task :build => API_OUT

  file API_OUT => API do
    sh "ruby #{API} > #{API_OUT}"
  end

  desc "Prints the build demo in #{API_OUT}"
  task :print => API_OUT do
    verbose(false) { sh "cat #{API_OUT}" }
  end

  desc "Runs the build demo in #{API_OUT} as an integration test"
  task :run => :print do
    puts
    print 'Running...'
    verbose(false) { sh "ruby #{API_OUT}" }
    puts 'OK'
  end
end

namespace :test do
  desc 'Run integration and unit tests'
  task :all => ['demo:run', :spec]
end


# -*- ruby -*-

guard 'rspec', cmd: 'bundle exec rspec', all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')          { 'spec' }
  watch(/spec\/support\/(.+)\.rb/)      { 'spec' }

  # TODO: run tree/*_spec.rb on changes of tree.rb

  watch(%r{^lib/(.+)\.rb$})             { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})             { |m| "spec/interaction" }

end

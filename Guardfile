# -*- ruby -*-

guard 'rspec', cmd: 'bundle exec rspec', all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')          { 'spec' }
  watch(/spec\/support\/(.+)\.rb/)      { 'spec' }

  # TODO: Reduce the next two rules to one with another regex
  watch(%r{^lib/(.+)\.rb$})             { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^lib/sycamore/(.+)\.rb$})    { |m| "spec/unit/#{m[1]}_spec.rb" }

  # TODO: dto.
  watch(%r{^lib/(.+)\.rb$})             { |m| "spec/interaction" }
  watch(%r{^lib/sycamore/(.+)\.rb$})    { |m| "spec/interaction" }
end

guard 'bundler' do
  watch('Gemfile')
  watch('machines.gemspec')
end

# Add
#   :cli => '-t focus'
# to focus specs

guard 'rspec', :spec_paths => ['spec/lib', 'spec/support_specs'] do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(machines|packages)(.+)\.rb$}) { |m| "spec/lib/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$}) { |m| "spec/support_specs/#{m[1]}_spec.rb" }

  # String watch patterns are matched with simple '=='
  watch('spec/spec_helper.rb') { "spec" }
  watch('lib/machines.rb') { "lib/machines_spec.rb" }
end


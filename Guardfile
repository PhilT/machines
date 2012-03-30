guard 'bundler' do
  watch('Gemfile')
  watch('machines.gemspec')
end

guard 'minitest', :test_file_patterns => 'lib/**/*_spec.rb', :cli => '-Ilib' do
  watch(%r{^spec/(.*)_spec\.rb$})
  watch(%r{^lib/(machines|packages)(.+)\.rb$}) { |m| "spec/lib/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$}) { |m| "spec/support_specs/#{m[1]}_spec.rb" }

  # String watch patterns are matched with simple '=='
  watch('lib/machines.rb') { "lib/machines_spec.rb" }
end


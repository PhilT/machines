require 'rake'
require 'yard'

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

YARD::Rake::YardocTask.new

task :install do
  result = `gem build #{Dir['*.gemspec']} 2>&1`
  if result =~ /Successfully built/
    gem_file = result.scan(/File:.*/).join.gsub('File: ', '')
    puts `gem install #{gem_file}`
    `rm #{gem_file}`
  end
end


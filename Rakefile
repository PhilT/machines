require 'yard'
require 'highline/import'
require 'rake'
require 'rake/testtask'

task :default => [:coverage, :acceptance, :yard, :install]

YARD::Rake::YardocTask.new

Rake::TestTask.new(:spec) do |t|
  t.libs << './spec'
  t.pattern = './spec/{support_specs,lib}/**/*_spec.rb'
end

Rake::TestTask.new(:acceptance) do |t|
  t.libs << './spec'
  t.pattern = './spec/{acceptance}/**/*_spec.rb'
end

desc 'Generate code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
  ENV['COVERAGE'] = nil
end

desc 'Build and install the gem'
task :install do
  gemspec_path = Dir['*.gemspec'].first
  spec = eval(File.read(gemspec_path))

  result = `gem build #{gemspec_path} 2>&1`
  if result =~ /Successfully built/
    system "gem uninstall -x #{spec.name} 2>&1"
    system "gem install #{spec.file_name} --no-rdoc --no-ri 2>&1"
  else
    raise result
  end
end

desc 'Run machines'
task :run do
  $LOAD_PATH << 'lib'
  require 'machines'
  Machines::Base.new.start(ARGV[1])
end

desc 'Git tags and sends the gem to rubygems'
task :release do
  gemspec_path = Dir['*.gemspec'].first
  spec = eval(File.read(gemspec_path))

  system "git tag -f -a v#{spec.version} -m 'Version #{spec.version}'"
  system "git push --tags"
  system "gem push #{spec.file_name}"
end


require 'yard'
require 'rspec/core/rake_task'
require 'highline/import'

task :default => [:coverage, :yard, :install] do
  puts '', $terminal.color('Done.', :bold, :blue)
end

YARD::Rake::YardocTask.new
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/unit/**/*_spec.rb'
end

desc 'Generate code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  puts '', $terminal.color('Running specs with code coverage', :bold, :blue)
  Rake::Task['spec'].invoke

  puts '', $terminal.color('Running integration specs', :bold, :blue)
  system('rspec spec/integration')
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

namespace :vm do
  desc 'Start the virtual machine in headless mode'
  task :start do
    system('VBoxManage startvm machinesvm --type headless')
  end

  desc 'Stop the virtual machine'
  task :stop do
    system('VBoxManage controlvm machinesvm savestate')
  end

  desc 'Shutdown the virtual machine'
  task :kill do
    system('VBoxManage controlvm machinesvm poweroff')
  end

  desc 'Restore last snapshot of virtual machine'
  task :restore => :stop do
    system('VBoxManage snapshot machinesvm restorecurrent')
  end

  desc 'Get virtual machine state'
  task :state do
    system('VBoxManage showvminfo machinesvm | grep State')
  end
end

desc 'Run machines'
task :run do
  $LOAD_PATH << 'lib'
  require 'machines'
  Machines::Base.new.start(ARGV[1])
end

desc 'takes the version in the gemspec creates a git tag and sends the gem to rubygems'
task :release do
  gemspec_path = Dir['*.gemspec'].first
  spec = eval(File.read(gemspec_path))

  system "git tag -f -a v#{spec.version} -m 'Version #{spec.version}'"
  system "git push --tags"
  system "gem push #{spec.file_name}"
end


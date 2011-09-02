require 'net/ssh'
require 'yard'
require 'rspec/core/rake_task'
require 'highline/import'

task :default => [:coverage, 'integration:non_vm', :yard, :install, :done]
task :all => [:coverage, 'integration:all', :yard, :install, :done]

task :done do
  puts '', $terminal.color('Done.', :bold, :blue)
end

YARD::Rake::YardocTask.new
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/{support_specs,lib}/**/*_spec.rb'
  t.rspec_opts = '-t ~vm'
end

desc 'Generate code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  puts '', $terminal.color('Running specs with code coverage', :bold, :blue)
  Rake::Task['spec'].invoke
  ENV['COVERAGE'] = nil
end

desc 'Run integration specs that require a VM'
namespace :integration do
  task :non_vm do
    puts '', $terminal.color('Running non VM integration specs', :bold, :blue)
    system('rspec spec/integration -t ~vm')
  end

  task :all do
    puts '', $terminal.color('Running all integration specs', :bold, :blue)
    system('rspec spec/integration')
  end
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

  namespace :win do
    desc 'Start the virtual machine in headless mode (on a Windows host)'
    task :start do
      ssh_virtualbox('startvm machinesvm')
    end

    desc 'Stop the virtual machine (on a Windows host)'
    task :stop do
      ssh_virtualbox('controlvm machinesvm savestate')
    end

    desc 'Shutdown the virtual machine (on a Windows host)'
    task :kill do
      ssh_virtualbox('controlvm machinesvm poweroff')
    end

    desc 'Restore last snapshot of virtual machine (on a Windows host)'
    task :restore => :stop do
      ssh_virtualbox('snapshot machinesvm restorecurrent')
    end

    desc 'Get virtual machine state (on a Windows host)'
    task :state do
      output = ssh_virtualbox('showvminfo machinesvm')
      puts "State: #{output.scan(/State:\s+(.*)/).first.first}"
    end
  end
end

def ssh_virtualbox command
  output = ''
  Net::SSH.start('winhost', 'phil', :password => 'password') do |ssh|
    output = ssh.exec!("C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage #{command}")
  end
  output
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


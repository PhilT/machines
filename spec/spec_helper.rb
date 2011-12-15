require 'fakefs/spec_helpers'

Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }
require 'machines'
include Machines
include Machines::Checks
application_dir = AppConf.application_dir

RSpec.configure do |c|
  c.include(Matchers)
  c.include(FakeFS::SpecHelpers)

  module AllModules
    include Core
    include AppSettings, Checks, Commandline, Configuration, Database, Ec2Machine
    include FileOperations, Installation, Machinesfile, Questions, Services
  end
  c.include(AllModules)

  c.before(:each) do
    AppConf.clear
    AppConf.passwords = []
    AppConf.commands = []
    AppConf.tasks = {}
    AppConf.application_dir = application_dir

    $debug = FakeOut.new
    $file = FakeOut.new
    $console = FakeOut.new
    Command.debug = Machines::Logger.new $debug
    Command.file = Machines::Logger.new $file
    Command.console = Machines::Logger.new $console, :truncate => true

    $input = MockStdin.new
    $output = MockStdout.new
    $terminal = HighLine.new($input, $output)
  end
end

def load_package name
  FakeFS.deactivate!
  @package_path = File.join(AppConf.application_dir, File.join('packages', "#{name}.rb"))
  @package = File.read(@package_path)
  FakeFS.activate!
end

def eval_package
  eval @package, nil, @package_path
end

def save_yaml contents, path
  File.open(path, 'w') do |f|
    YAML.dump(contents, f)
  end
end


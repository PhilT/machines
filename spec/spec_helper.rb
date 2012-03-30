$LOAD_PATH << 'lib'

require 'bundler/setup'
require 'minitest/spec'
require 'mocha'
require 'stringio'
require 'fakefs/safe'

Dir['spec/support/*.rb'].each {|file| require File.join('./spec', 'support', File.basename(file)) }
require 'machines'
application_dir = $conf.application_dir

# This is done so that Machines::Core.run doesn't collide with MiniTest::Unit::TestCase.run when included
module Machines::Core
  alias :run_command :run
  remove_method :run
end
MiniTest::Spec.add_setup_hook do |klass|
  klass.instance_eval do
    alias :run :run_command if respond_to?(:run_command)
  end
end

MiniTest::Spec.add_setup_hook do
  include Machines::Checks

  $conf.clear
  $conf.passwords = []
  $conf.commands = []
  $conf.tasks = {}
  $conf.application_dir = application_dir

  $debug = FakeOut.new
  $file = FakeOut.new
  $console = FakeOut.new
  Machines::Command.debug = Machines::Logger.new $debug
  Machines::Command.file = Machines::Logger.new $file
  Machines::Command.console = Machines::Logger.new $console, :truncate => true

  $input = MockStdin.new
  $output = MockStdout.new
  $terminal = HighLine.new($input, $output)
  FakeFS.activate!
  FileUtils.mkdir_p 'tmp'
end

MiniTest::Spec.add_teardown_hook do
  FakeFS.deactivate!
  FakeFS::FileSystem.clear
end

module MiniTest
  module Assertions
    def capture_io
      input = MockStdin.new
      output = StringIO.new
      $terminal = HighLine.new(input, output)

      yield

      return output.string
    end
  end
end

class MiniTest::Spec::Package < MiniTest::Spec
  include Machines
  include AppSettings, CloudMachine, Commandline, Configuration, Core, Database
  include FileOperations, Installation, Machinesfile, Questions, Services
end

MiniTest::Spec.register_spec_type(/packages\//, MiniTest::Spec::Package)


def load_package name
  FakeFS.deactivate!
  @package_path = File.join($conf.application_dir, File.join('packages', "#{name}.rb"))
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

def colored string, color
  ending = string.scan(/(\n|\r)$/).flatten.first
  string.sub!(/(\n|\r)$/, '')
  $terminal.color(string, color.to_sym) + ending.to_s
end

require 'minitest/autorun'


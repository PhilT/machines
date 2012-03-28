$LOAD_PATH << 'lib'

require 'bundler/setup'
require 'minitest/spec'
require 'mocha'
require 'stringio'
require 'fakefs/safe'

Dir['spec/support/*.rb'].each {|file| require File.join('./spec', 'support', File.basename(file)) }
require 'machines'
application_dir = AppConf.application_dir

# This is done so that Machines::Core.run doesn't collide with MiniTest::Unit::TestCase.run when included
Machines::Core.module_eval do
  alias :run_command :run
  remove_method :run
end

MiniTest::Unit::TestCase.add_setup_hook do
  include Machines::Checks

  AppConf.clear
  AppConf.passwords = []
  AppConf.commands = []
  AppConf.tasks = {}
  AppConf.application_dir = application_dir

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

MiniTest::Unit::TestCase.add_teardown_hook { FakeFS.deactivate! }

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

require 'minitest/autorun'


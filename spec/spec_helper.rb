$LOAD_PATH << 'lib'

require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/setup'
require 'stringio'
require 'fakefs/safe'

Dir['spec/support/*.rb'].each {|file| require File.join('./spec', 'support', File.basename(file)) }
require 'machines'
$application_dir = $conf.application_dir

include Machines
modules = %w(Checks Configuration Database FileOperations Installation Questions Services)
modules.each { |m| include eval("Machines::Commands::#{m}") }

module MiniTestSetup
  def before_setup
    super
    $conf.clear
    $conf.passwords = []
    $conf.commands = []
    $conf.tasks = {}
    $conf.application_dir = $application_dir

    $input = StringIO.new
    $output = StringIO.new
    $terminal = HighLine.new($input, $output)

    $debug = FakeOut.new
    $file = FakeOut.new
    $console = FakeOut.new
    Machines::Command.debug = Machines::Logger.new $debug
    Machines::Command.file = Machines::Logger.new $file
    Machines::Command.console = Machines::Logger.new $console, :truncate => true

    FakeFS.activate!
    FileUtils.mkdir_p 'tmp'
  end

  def after_teardown
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
    super
  end
end

class MiniTest::Test
  include MiniTestSetup
end

module MiniTest
  module Assertions
    def capture_io
      yield
      return $output.string
    end
  end
end

class Machines::Core
  def eval_package content, name
    eval content, nil, "lib/packages/#{name}.rb"
  end

  def queued_commands
    $conf.commands.map(&:info).join("\n")
  end
end

class MiniTest::Spec::Package < MiniTest::Spec
  def core
    @core ||= Core.new
  end

  def load_package
    FakeFS.deactivate!
    @package_name = File.basename(self.class.name).split('::').first
    @package = File.read File.join($conf.application_dir, 'packages', "#{@package_name}.rb")
    FakeFS.activate!
  end

  def eval_package
    core.eval_package(@package, @package_name)
  end

  def queued_commands
    $conf.commands.map(&:info).join("\n")
  end

  def before_setup
    super
    load_package
  end
end

MiniTest::Spec.register_spec_type(/packages\//, MiniTest::Spec::Package)

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


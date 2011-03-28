Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }
require 'machines'
include Machines::Checks

UNIT_PROJECT_DIR = File.join(Dir.pwd, 'tmp/unit')
FileUtils.rm_rf UNIT_PROJECT_DIR
FileUtils.mkdir_p UNIT_PROJECT_DIR
FileUtils.cp_r('lib/template/.', 'tmp/unit')

RSpec.configure do |c|
  c.before(:each, :type => :unit) do
    AppConf.project_dir = UNIT_PROJECT_DIR
  end

  c.before(:each, :type => :integration) do
    AppConf.project_dir = File.join(Dir.pwd, 'tmp/integration')
  end

  c.before(:each) do
    @added = []
    @checks = []
  end
end

module FakeAddHelper
  def add to_add, check
    @added << to_add
    @checks << check
  end
end

class MockStdOut
  attr_accessor :buffer
  def initialize
    @buffer = ""
  end

  def print string
    @buffer << string
  end

  def flush
  end

  def puts string
    print string << "\n"
  end

  def tty?
    false
  end
end

class MockStdIn
  attr_accessor :buffer
  def initialize input = ''
    @buffer = input
  end

  def gets
    @buffer
  end
end


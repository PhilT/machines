require 'fakefs/spec_helpers'

Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }
require 'machines'
include Machines::Checks
include Machines

UNIT_PROJECT_DIR = File.join(Dir.pwd, 'tmp/unit')
FileUtils.rm_rf UNIT_PROJECT_DIR
FileUtils.mkdir_p UNIT_PROJECT_DIR
FileUtils.cp_r('lib/template/.', 'tmp/unit')

RSpec.configure do |c|
  c.include(Matchers)
  c.include(FakeFS::SpecHelpers)


  c.before(:each, :type => :unit) do
    AppConf.passwords = []
    AppConf.commands = []
    AppConf.from_hash(:user => {})
    AppConf.project_dir = UNIT_PROJECT_DIR
    $input = MockStdIn.new
    $output = MockStdOut.new
    $terminal = HighLine.new($input, $output)
  end

  c.before(:all, :type => :integration) do
    AppConf.project_dir = File.join(Dir.pwd, 'tmp/integration')
    $input = MockStdIn.new
    $output = MockStdOut.new
    $terminal = HighLine.new($input, $output)
  end
end


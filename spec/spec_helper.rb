require 'fakefs/spec_helpers'

Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }
require 'machines'
include Machines
include Machines::Checks
application_dir = AppConf.application_dir

RSpec.configure do |c|
  c.include(Matchers)
  c.include(FakeFS::SpecHelpers)

  c.before(:each) do
    AppConf.clear
    AppConf.passwords = []
    AppConf.commands = []
    AppConf.tasks = {}
    AppConf.from_hash(:user => {})
    AppConf.application_dir = application_dir
    AppConf.project_dir = '/tmp'
    $input = MockStdin.new
    $output = MockStdout.new
    $terminal = HighLine.new($input, $output)
  end
end


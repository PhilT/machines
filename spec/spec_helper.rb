require 'fakefs/spec_helpers'

Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }
require 'machines'
include Machines
include Machines::Checks

RSpec.configure do |c|
  c.include(Matchers)
  c.include(FakeFS::SpecHelpers)

  c.before(:each) do
    AppConf.passwords = []
    AppConf.commands = []
    AppConf.from_hash(:user => {})
    AppConf.project_dir = '/tmp'
    $input = MockStdIn.new
    $output = MockStdOut.new
    $terminal = HighLine.new($input, $output)
  end
end


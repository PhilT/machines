require 'fileutils'
require 'integration/common_steps'

Dir['spec/support/*.rb'].each {|file| require File.join('support', File.basename(file)) }

$project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  c.include(Matchers)
  c.include(CommonSteps)

  c.before(:each) do
    FileUtils.cd File.join($project_dir, 'tmp')
    load '../lib/machines.rb'
    AppConf.project_dir.should == File.join($project_dir, 'tmp')
    FileUtils.rm_rf 'project'

    $file = FakeOut.new
    $console = FakeOut.new
    AppConf.file = Machines::Logger.new $file
    AppConf.console = Machines::Logger.new $console, :truncate => true

    $input = MockStdin.new
    $output = MockStdout.new
    $terminal = HighLine.new($input, $output)
  end
end


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

    $input = MockStdin.new
    $output = MockStdout.new
    $terminal = HighLine.new($input, $output)
    start_vm
    ensure_vm_exists_and_can_connect
  end

  c.after(:each) do
    stop_vm
  end
end


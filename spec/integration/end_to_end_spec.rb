require 'fileutils'

require 'support/mock_stdin'
require 'support/mock_stdout'
require 'support/cli_matchers'
require 'support/end_to_end_steps'

describe 'End to End Test' do
  include Matchers
  include EndToEndSteps

  before do
    @pwd = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    @pwd.should == Dir.pwd
    FileUtils.cd File.join(@pwd, 'tmp')

    require 'machines'
    AppConf.project_dir.should == File.join(@pwd, 'tmp')

    FileUtils.rm_rf 'project'
    $input = MockStdin.new
    $output = MockStdout.new
    $terminal = HighLine.new($input, $output)

    start_vm

    begin
      ensure_vm_exists_and_can_connect
    rescue
      stop_vm
    end
  end

  after do
    FileUtils.cd(@pwd)
  end


  it 'generates template, asks questions and runs build script' do
    generates_template
    generates_htpasswd_to_limit_access_to_staging
    checks_machinesfile
  end

end


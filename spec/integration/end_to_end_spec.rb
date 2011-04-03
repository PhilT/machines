require 'fileutils'

require 'support/mock_highline'
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
    $input = MockStdIn.new
    $output = MockStdOut.new
    $terminal = HighLine.new($input, $output)

    ensure_vm_exists_and_can_connect
  end

  after do
    FileUtils.cd(@pwd)
  end


  it 'generates template, asks questions and runs build script' do
    can_generate_template
    can_generate_htpasswds_for_staging
  end

end


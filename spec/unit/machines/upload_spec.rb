require 'spec_helper'

describe Command do
  include Machines::Logger
  include FakeFS::SpecHelpers

  subject { Upload.new('local', 'remote', 'check') }

  describe 'initialize' do
    it 'sets line, local, remote and check' do
      subject.command.should be_nil
      subject.local.should == 'local'
      subject.remote.should == 'remote'
      subject.check.should == 'check'
    end
  end

  describe 'run' do

    before(:each) do
      HighLine.use_color = false
      @log = MockStdOut.new
      AppConf.log = @log
      @mock_ssh = mock Net::SSH
      @mock_scp = mock Net::SCP, :session => @mock_ssh
      Command.scp = @mock_scp
      @mock_ssh.stub(:exec!).with('check').and_return "CHECK PASSED"
    end

    it 'uploads local to remote with logging' do
      @mock_scp.should_receive(:upload!).with('local', 'remote', {:recursive => false})

      subject.run

      @log.buffer.should == <<-LOG
UPLOAD local to remote
CHECK PASSED
LOG
      "UPLOAD local to remote".should be_displayed
    end

    it 'uploads a directory source' do
      FileUtils.mkdir_p('local')
      @mock_scp.should_receive(:upload!).with('local', 'remote', {:recursive => true})

      subject.run

    end
  end

  describe 'info' do
    it 'returns the command' do
      subject.info.should == 'UPLOAD local to remote'
    end
  end

  describe '==' do
    it 'matches when line, command and check are the same' do
      subject.should == Upload.new('local', 'remote', 'check')
    end

    it 'does not match when local is different' do
      subject.should_not == Upload.new('loca', 'remote', 'check')
    end

    it 'does not match when remote is different' do
      subject.should_not == Upload.new('local', 'reote', 'check')
    end

    it 'does not match when check is different' do
      subject.should_not == Upload.new('local', 'remote', 'ch')
    end
  end
end


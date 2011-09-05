require 'spec_helper'

describe Command do
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
      AppConf.commands = [subject]
      AppConf.log_only = false
      @mock_ssh = mock Net::SSH
      @mock_scp = mock Net::SCP, :session => @mock_ssh
      Command.scp = @mock_scp
      @mock_ssh.stub(:exec!).with('export TERM=linux && check').and_return "CHECK PASSED"
    end

    it 'uploads local to remote with logging' do
      @mock_scp.should_receive(:upload!).with('local', 'remote', {:recursive => false})
      subject.run

      "UPLOAD local to remote\n".should be_logged as_highlight
      "CHECK PASSED\n".should be_logged as_success
      "100% UPLOAD local to remote\r".should be_displayed
      "100% UPLOAD local to remote\n".should be_displayed as_success
    end

    it 'logs with newline when logging only' do
      @mock_scp.stub(:upload!)
      AppConf.log_only = true
      subject.run

      "100% UPLOAD local to remote\n".should be_displayed
    end

    it 'logs with return when log_only not specified' do
      @mock_scp.stub(:upload!)
      AppConf.log_only = nil
      subject.run

      "100% UPLOAD local to remote\r".should be_displayed
    end

    it 'uploads a directory source' do
      FileUtils.mkdir_p('local')
      @mock_scp.should_receive(:upload!).with('local', 'remote', {:recursive => true})

      subject.run
    end

    it 'uploads an in memory buffer' do
      buffer = NamedBuffer.new('name', 'a buffer')
      subject = Upload.new(buffer, 'remote', 'check')
      AppConf.commands = [subject]
      @mock_scp.should_receive(:upload!).with(buffer, 'remote', {:recursive => false})
      subject.run
    end
  end

  describe 'info' do
    it 'contains source and destination paths and UPLOAD' do
      subject.info.should == 'UPLOAD local to remote'
    end

    context 'when local is a buffer' do
      subject { Upload.new(NamedBuffer.new('name', 'a buffer'), 'remote', 'check') }
      it 'contains name of the buffer' do
        subject.info.should == 'UPLOAD buffer from name to remote'
      end

      it 'handles nil names' do
        subject = Upload.new(NamedBuffer.new(nil, 'a buffer'), 'remote', 'check')
        subject.info.should == "UPLOAD unnamed buffer to remote"
      end
    end
  end
end


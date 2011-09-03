require 'spec_helper'

describe Command do
  subject { Command.new('command', 'check') }

  describe 'initialize' do
    it 'sets line, command, check' do
      subject.command.should == 'command'
      subject.check.should == 'check'
    end
  end

  describe 'run' do
    before(:each) do
      AppConf.commands = [subject]
      @mock_ssh = mock Net::SSH
      @mock_ssh.stub(:exec!).and_return 'result'
      @mock_ssh.stub(:exec!).with('export TERM=linux && command').and_return "result"
      @mock_ssh.stub(:exec!).with('check').and_return "CHECK PASSED"
      Command.scp = mock Net::SCP, :session => @mock_ssh
    end

    it 'does not execute command when logging only' do
      @mock_ssh.should_not_receive :exec!
      AppConf.log_only = true
      subject.run
    end

    describe 'check_result' do
      it 'returns NOT CHECKED when nothing to execute' do
        subject = Command.new('command', nil)
        AppConf.commands = [subject]
        @mock_ssh.should_not_receive(:exec!).with(nil)
        subject.run

        "100% RUN    command\r".should be_displayed
        "100% RUN    command\n".should be_displayed as_warning

        "RUN    command\n".should be_logged as_highlight
        "result\n".should be_logged
        "NOT CHECKED\n".should be_logged as_warning
      end
    end

    describe 'logs' do
      before(:each) do
        AppConf.log_only = false
      end

      it 'to screen using newline instead of return when logging only' do
        AppConf.log_only = true
        subject.run

        "100% RUN    command\n".should be_displayed
      end

      it 'defaults screen logging to return' do
        AppConf.log_only = nil
        subject.run

        "100% RUN    command\r".should be_displayed
      end

      it 'successful command to screen and file' do
        subject.run

        "100% RUN    command\r".should be_displayed
        "100% RUN    command\n".should be_displayed as_success

        "RUN    command\n".should be_logged as_highlight
        "result\n".should be_logged
        "CHECK PASSED\n".should be_logged as_success
      end

      it 'successful sudo command to screen and file' do
        AppConf.user.pass = 'userpass'
        subject.use_sudo
        subject.run

        "100% SUDO   command\r".should be_displayed
        "100% SUDO   command\n".should be_displayed as_success

        "SUDO   command\n".should be_logged as_highlight
        "result\n".should be_logged
        "CHECK PASSED\n".should be_logged as_success
      end

      it 'unsuccesful command to screen and file' do
        @mock_ssh.stub(:exec!).with('check').and_return "CHECK FAILED"

        subject.run

        "100% RUN    command\r".should be_displayed
        "100% RUN    command\n".should be_displayed as_failure

        "RUN    command\n".should be_logged as_highlight
        "result\n".should be_logged
        "CHECK FAILED\n".should be_logged as_failure
      end

      it 'ensure failures are always logged even when exceptions raised' do
        @mock_ssh.should_receive(:exec!).with('check').and_raise Exception.new

        lambda {subject.run}.should raise_error Exception

        "100% RUN    command\r".should be_displayed
        "100% RUN    command\n".should be_displayed as_failure

        "RUN    command\n".should be_logged as_highlight
        "result\n".should be_logged
        "Exception\n".should be_logged as_failure
      end

      it 'ensure logging failures do not stop app exiting gracefully' do
        @mock_ssh.should_receive(:exec!).with('check').and_raise Exception.new
        AppConf.file.stub(:log)
        AppConf.file.should_receive(:log).with('Exception', :color => :failure).and_raise ArgumentError
        lambda {subject.run}.should_not raise_error ArgumentError
      end

      it 'ensure console failures do not stop app exiting gracefully' do
        @mock_ssh.should_receive(:exec!).with('check').and_raise Exception.new
        AppConf.console.stub(:log)
        AppConf.console.should_receive(:log).with('100% RUN    command', :color => :failure).and_raise ArgumentError
        lambda {subject.run}.should_not raise_error ArgumentError
      end
    end

    it 'wraps command execution in sudo with a password' do
      AppConf.user.pass = 'userpass'
      @mock_ssh.should_receive(:exec!).with("echo userpass | sudo -S sh -c 'export TERM=linux && command'").and_return "result"

      subject.use_sudo
      subject.run
    end

    it 'wraps command execution in sudo with no password' do
      @mock_ssh.should_receive(:exec!).with("sudo -S sh -c 'export TERM=linux && command'").and_return "result"

      subject.use_sudo
      subject.run
    end
  end

  describe 'info' do
    it 'returns the command' do
      subject.info.should == 'RUN    command'
    end
  end

  describe '==' do
    it 'matches when line, command and check are the same' do
      subject.should == Command.new('command', 'check')
    end

    it 'does not match when command is different' do
      subject.should_not == Command.new('comm', 'check')
    end

    it 'does not match when check is different' do
      subject.should_not == Command.new('command', 'ch')
    end
  end
end


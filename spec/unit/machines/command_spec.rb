require 'spec_helper'

describe Command do
  include Machines::Logger

  subject { Command.new('command', 'check') }

  describe 'initialize' do
    it 'sets line, command, check' do
      subject.command.should == 'command'
      subject.check.should == 'check'
    end
  end

  describe 'run' do
    it 'wraps command execution in logging' do
      HighLine.use_color = false
      log = MockStdOut.new
      AppConf.log = log

      mock_ssh = mock Net::SSH
      mock_ssh.stub(:exec!).with('export TERM=linux && command').and_return "result of command"
      mock_ssh.stub(:exec!).with('check').and_return "CHECK PASSED"
      Command.scp = mock Net::SCP, :session => mock_ssh

      subject.run

      log.buffer.should == <<-LOG
RUN    command
result of command
CHECK PASSED
LOG
      "RUN    command".should be_displayed
    end

    it 'wraps command execution in sudo' do
      HighLine.use_color = false
      log = MockStdOut.new
      AppConf.log = log
      AppConf.user.pass = 'userpass'

      mock_ssh = mock Net::SSH
      mock_ssh.stub(:exec!).with("echo userpass | sudo -S sh -c 'export TERM=linux && command'").and_return "result of command"
      mock_ssh.stub(:exec!).with('check').and_return "CHECK PASSED"
      Command.scp = mock Net::SCP, :session => mock_ssh

      subject.use_sudo
      subject.run

      log.buffer.should == <<-LOG
SUDO   command
result of command
CHECK PASSED
LOG
      "SUDO   command".should be_displayed
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


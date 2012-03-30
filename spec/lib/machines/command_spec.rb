require 'spec_helper'

describe Machines::Command do
  subject { Machines::Command.new('command', 'check') }
  describe 'initialize' do
    it 'sets line, command, check' do
      subject.command.must_equal 'command'
      subject.check.must_equal 'check'
    end
  end

  describe 'run' do
    before(:each) do
      $conf.commands = [subject]
      @mock_ssh = mock 'Net::SSH'
      @mock_ssh.stubs(:exec!).returns 'result'
      @mock_ssh.stubs(:exec!).with('export TERM=linux && command').returns "result"
      @mock_ssh.stubs(:exec!).with('export TERM=linux && check').returns "CHECK PASSED"
      Machines::Command.scp = stub 'Net::SCP', :session => @mock_ssh
    end

    it 'does not execute command when logging only' do
      @mock_ssh.expects(:exec!).never
      $conf.log_only = true
      subject.run
    end

    describe 'check_result' do
      it 'returns NOT CHECKED when nothing to execute' do
        subject = Machines::Command.new('command', nil)
        $conf.commands = [subject]
        @mock_ssh.expects(:exec!).with(nil).never
        subject.run

        $console.next.must_equal "100% RUN    command\r"
        $console.next.must_equal colored("100% RUN    command\n", :warning)

        $file.next.must_equal colored("RUN    command\n", :highlight)
        $file.next.must_equal "result\n"
        $file.next.must_equal colored("NOT CHECKED\n", :warning)
      end
    end

    describe 'logs' do
      before(:each) do
        $conf.log_only = false
      end

      it 'to screen using newline instead of return when logging only' do
        $conf.log_only = true
        subject.run

        $console.next.must_equal "100% RUN    command\n"
      end

      it 'defaults screen logging to return' do
        $conf.log_only = nil
        subject.run

        $console.next.must_equal "100% RUN    command\r"
      end

      it 'successful command to screen and file' do
        subject.run

        $console.next.must_equal "100% RUN    command\r"
        $console.next.must_equal colored("100% RUN    command\n", :success)

        $file.next.must_equal colored("RUN    command\n", :highlight)
        $file.next.must_equal "result\n"
        $file.next.must_equal colored("CHECK PASSED\n", :success)
      end

      it 'successful sudo command to screen and file' do
        $conf.password = 'userpass'
        @mock_ssh.stubs(:exec!).with("echo userpass | sudo -S bash -c 'export TERM=linux && check'").returns 'CHECK PASSED'
        subject.use_sudo
        subject.run

        $console.next.must_equal "100% SUDO   command\r"
        $console.next.must_equal colored("100% SUDO   command\n", :success)

        $file.next.must_equal colored("SUDO   command\n", :highlight)
        $file.next.must_equal "result\n"
        $file.next.must_equal colored("CHECK PASSED\n", :success)
      end

      it 'unsuccesful command to screen and file' do
        @mock_ssh.stubs(:exec!).with('export TERM=linux && check').returns "CHECK FAILED"

        subject.run

        $console.next.must_equal "100% RUN    command\r"
        $console.next.must_equal colored("100% RUN    command\n", :failure)

        $file.next.must_equal colored("RUN    command\n", :highlight)
        $file.next.must_equal "result\n"
        $file.next.must_equal colored("CHECK FAILED\n", :failure)
      end

      it 'ensure failures are always logged even when exceptions raised' do
        @mock_ssh.expects(:exec!).with('export TERM=linux && check').raises Exception

        lambda {subject.run}.must_raise Exception

        $console.next.must_equal "100% RUN    command\r"
        $console.next.must_equal colored("100% RUN    command\n", :failure)

        $file.next.must_equal colored("RUN    command\n", :highlight)
        $file.next.must_equal "result\n"
        $file.next.must_equal colored("Exception\n", :failure)
      end

      it 'ensure logging failures do not stop app exiting gracefully' do
        @mock_ssh.expects(:exec!).with('export TERM=linux && check').raises Exception
        Machines::Command.file.stubs(:log)
        Machines::Command.file.expects(:log).with('Exception', :color => :failure).raises ArgumentError
        begin
          subject.run
        rescue Exception
        rescue ArgumentError
          flunk 'Expecting Exception to be raised but not ArgumentError'
        end
      end

      it 'ensure console failures do not stop app exiting gracefully' do
        @mock_ssh.expects(:exec!).with('export TERM=linux && check').raises Exception
        Machines::Command.console.stubs(:log)
        Machines::Command.console.expects(:log).with('100% RUN    command', :color => :failure).raises ArgumentError
        begin
          subject.run
        rescue Exception
        rescue ArgumentError
          flunk 'Expecting Exception to be raised but not ArgumentError'
        end
      end
    end

    it 'wraps command execution in sudo with a password' do
      $conf.password = 'userpass'
      @mock_ssh.expects(:exec!).with("echo userpass | sudo -S bash -c 'export TERM=linux && command'").returns "result"

      subject.use_sudo
      subject.run
    end

    it 'wraps command execution in sudo with no password' do
      @mock_ssh.expects(:exec!).with("sudo -S bash -c 'export TERM=linux && command'").returns "result"

      subject.use_sudo
      subject.run
    end

    it 'wraps check execution in sudo with a password' do
      $conf.password = 'userpass'
      @mock_ssh.expects(:exec!).with("echo userpass | sudo -S bash -c 'export TERM=linux && check'").returns 'CHECK PASSED'

      subject.use_sudo
      subject.run
    end

    it 'wraps check execution in sudo with no password' do
      @mock_ssh.expects(:exec!).with("sudo -S bash -c 'export TERM=linux && check'").returns 'CHECK PASSED'

      subject.use_sudo
      subject.run
    end
  end

  describe 'progress' do
    it 'returns correct percentage' do
      $conf.commands = 200.times.map { Machines::Command.new('command', 'check') }
      $conf.commands[10].send('progress').must_equal '  6% '
    end
  end

  describe 'info' do
    it 'returns the command' do
      subject.info.must_equal 'RUN    command'
    end
  end
end


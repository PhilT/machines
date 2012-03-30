require 'spec_helper'

describe Machines::Upload do
  subject { Machines::Upload.new('local', 'remote', 'check') }

  describe 'initialize' do
    it 'sets line, local, remote and check' do
      subject.command.must_equal nil
      subject.local.must_equal 'local'
      subject.remote.must_equal 'remote'
      subject.check.must_equal 'check'
    end
  end

  describe 'run' do
    before(:each) do
      $conf.commands = [subject]
      $conf.log_only = false
      @mock_ssh = mock 'Net::SSH'
      @mock_scp = stub 'Net::SCP', :session => @mock_ssh
      Machines::Command.scp = @mock_scp
      @mock_ssh.stubs(:exec!).with('export TERM=linux && check').returns "CHECK PASSED"
    end

    it 'uploads local to remote with logging' do
      @mock_scp.expects(:upload!).with('local', 'remote', {:recursive => false})
      subject.run

      $file.next.must_equal colored("UPLOAD local to remote\n", :highlight)
      $file.next.must_equal colored("CHECK PASSED\n", :success)
      $console.next.must_equal "100% UPLOAD local to remote\r"
      $console.next.must_equal colored("100% UPLOAD local to remote\n", :success)
    end

    it 'logs with newline when logging only' do
      @mock_scp.stubs(:upload!)
      $conf.log_only = true
      subject.run

      $console.next.must_equal "100% UPLOAD local to remote\n"
    end

    it 'logs with return when log_only not specified' do
      @mock_scp.stubs(:upload!)
      $conf.log_only = nil
      subject.run

      $console.next.must_equal "100% UPLOAD local to remote\r"
    end

    it 'uploads a folder source' do
      FileUtils.mkdir_p('local')
      @mock_scp.expects(:upload!).with('local', 'remote', {:recursive => true})

      subject.run
    end

    it 'uploads an in memory buffer' do
      buffer = NamedBuffer.new('name', 'a buffer')
      subject = Machines::Upload.new(buffer, 'remote', 'check')
      $conf.commands = [subject]
      @mock_scp.expects(:upload!).with(buffer, 'remote', {:recursive => false})
      subject.run
    end
  end

  describe 'info' do
    it 'contains source and destination paths and UPLOAD' do
      subject.info.must_equal 'UPLOAD local to remote'
    end

    describe 'when local is a buffer' do
      subject { Machines::Upload.new(NamedBuffer.new('name', 'a buffer'), 'remote', 'check') }
      it 'contains name of the buffer' do
        subject.info.must_equal 'UPLOAD buffer from name to remote'
      end

      it 'handles nil names' do
        subject = Machines::Upload.new(NamedBuffer.new(nil, 'a buffer'), 'remote', 'check')
        subject.info.must_equal "UPLOAD unnamed buffer to remote"
      end
    end
  end
end


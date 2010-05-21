require 'spec/spec_helper'

describe 'Machines' do
  before(:each) do
    @commands = []
    @password = 'default'
  end

  describe 'new' do
    before(:each) do
      should_receive(:discover_users)
    end

    it 'should raise errors' do
      lambda{Machines::Base.new {}}.should raise_error 'Password not set'
    end
  end

  describe 'start' do
    it 'should run commands in test mode' do
      should_receive(:run_commands)
      start 'test'
    end

    it 'should run commands in install mode' do
      @host = 'host'
      should_receive(:enable_root_login)
      mock_ssh = mock 'Ssh'
      Net::SSH.should_receive(:start).with('host', 'root', {:password => Machines::TEMP_PASSWORD, :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield mock_ssh
      should_receive(:run_commands).with mock_ssh
      should_receive(:disable_root_login)

      start 'install'
    end

    it 'should not do anything when unknown command is specified' do
      Net::SSH.should_not_receive(:start)
      should_not_receive(:run_commands)
      start 'something'
    end
  end

  describe 'discover_users' do
    it 'should find users through folder list' do
      Dir.stub!(:[]).and_return ['users/first', 'users/another']
      discover_users
      @users.should == ['first', 'another']
    end
  end

  describe 'run_commands' do
    before(:each) do
      @passwords = {}
      @output = ''
      stub!(:print)
      stub!(:log_to)
      stub!(:log_result_to_file)
    end

    it 'should display all commands queued in the @commands array' do
      @commands = [['1', 'command 1'], ['2', 'command 2']]
      should_receive(:log_to).with(:screen, '1)   command 1')
      should_receive(:log_to).with(:screen, '2)   command 2')
      run_commands
    end

    it 'should run all commands queued in the @commands array' do
      @commands = [['1', 'command 1', 'check1'], ['2', 'command 2', 'check2']]
      mock_ssh = mock('Ssh')
      mock_ssh.should_receive(:exec!).with('command 1').and_return ''
      mock_ssh.should_receive(:exec!).with('check1').and_return ''
      mock_ssh.should_receive(:exec!).with('command 2').and_return ''
      mock_ssh.should_receive(:exec!).with('check2').and_return ''
      run_commands mock_ssh
    end

    it 'should run upload command' do
      @commands = [['1', ['from', 'to'], 'check1']]
      @host = 'host'
      mock_ssh = mock('Ssh')
      mock_ssh.should_receive(:exec!).with('check1').and_return ''
      mock_scp = mock('Scp')
      Net::SCP.should_receive(:start).with('host', 'root', {:password => Machines::TEMP_PASSWORD, :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield mock_scp
      mock_scp.should_receive(:upload!).with 'from', 'to'
      run_commands mock_ssh
    end

    it 'should raise errors when command or name is missing' do
      stub!(:display)
      @commands = [[nil, 'command']]
      lambda{run_commands}.should raise_error(ArgumentError)
      @commands = [['cmd', nil]]
      lambda{run_commands}.should raise_error(ArgumentError)
    end

    it "should catch SCP errors and display message" do
      @commands = [['1', ['from/path', 'to/path'], 'check1']]
      @host = 'host'
      mock_ssh = mock('Ssh', :exec! => nil)
      mock_scp = mock('Scp')
      mock_scp.should_receive(:upload!).and_raise 'an error'
      Net::SCP.should_receive(:start).with('host', 'root', {:password => Machines::TEMP_PASSWORD, :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield mock_scp
      should_receive(:log_to).with(:file, "FAILED\n\n")
      run_commands mock_ssh
    end
  end

  describe 'enable_root_login' do
    it 'should set the root password ' do
      mock_ssh = mock('Ssh')
      @host = 'host'
      Net::SSH.should_receive(:start).with('host', Machines::DEFAULT_IDENTITY, {:password => Machines::DEFAULT_IDENTITY, :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with "echo #{Machines::TEMP_PASSWORD} | sudo -S usermod -p #{Machines::TEMP_PASSWORD_ENCRYPTED} root"
      enable_root_login
    end
  end

  describe 'disable_root_login' do
    it 'should remove the root password on the remote machine' do
      mock_ssh = mock('Ssh')
      @host = 'host'
      Net::SSH.should_receive(:start).with('host', 'root', {:password => 'ubuntu', :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with 'passwd -l root'
      disable_root_login
    end
  end

end


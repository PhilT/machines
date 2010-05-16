require 'spec/spec_helper'

describe 'Machines' do
  before(:each) do
    @commands = []
    @log = []
  end

  def log message
    @log << message
  end

  describe 'machine' do
    it 'should set environment, apps and role when it matches the configuration specified' do
      @config_name = 'config'
      machine 'config', :test, {:apps => ['app', 'another'], :role => 'role'}
      @environment.should == :test
      @apps.should == ['app', 'another']
      @role.should == 'role'
    end

    it 'should not set anything when it does not match specified configuration' do
      machine 'config', :test, {:apps => ['app', 'another'], :role => 'role'}
      @environment.should be_nil
      @apps.should be_nil
      @role.should be_nil
    end
  end

  describe 'development?' do
    it do
      @environment = :development
      development?.should be_true
    end

    it do
      development?.should be_false
    end
  end

  describe 'password' do
    it 'should add a password to existing passwords' do
      @passwords = {'app' => 'password'}
      password 'another', 'anotherpass'
      @passwords.should == {'app' => 'password', 'another' => 'anotherpass'}
    end

    it 'should add a password to empty passwords' do
      password 'app', 'newpass'
      @passwords.should == {'app' => 'newpass'}
    end
  end

  describe 'configure' do
    it 'should set various instance variables' do
      configure 'name', 'host', 'user', 'machine', 'dbmaster'
      @config_name.should == 'name'
      @host.should == 'host'
      @machinename.should == 'machine'
      @dbmaster.should == 'dbmaster'
    end
  end

  describe 'start' do
    before(:each) do
      should_receive(:validate_configuration)
      should_receive(:discover_users)
    end

    it 'should run commands in test mode' do
      should_receive(:run_commands)
      start 'test'
    end

    it 'should run commands in install mode' do
      @host = 'host'
      should_receive(:enable_root_login)
      mock_ssh = mock 'Ssh'
      Net::SSH.should_receive(:start).with('host', 'root', :password => TEMP_PASSWORD).and_yield mock_ssh
      should_receive(:run_commands).with mock_ssh
      should_receive(:disable_root_login)

      start 'install'
    end

    it 'should not do anything when unknown command is specified' do
      should_not_receive(:run_commands)
      start 'something'
    end
  end

  describe 'validate_configuration' do
    it 'should return true when valid' do
      @apps = 'app'
      lambda{validate_configuration}.should_not raise_error
    end
    it 'should log an error when configuration could not be selected' do
      @config_name = 'config'
      lambda{validate_configuration}.should raise_error(ArgumentError, "config does not exist. Check machine configurations in your Machinesfile.")
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
    end

    it 'should display all commands queued in the @commands array' do
      @commands = [['cmd1', 'command 1'], ['cmd2', 'command 2']]
      run_commands
      @log.should == ['cmd1            command 1', 'cmd2            command 2']
    end

    it 'should run all commands queued in the @commands array' do
      @commands = [['cmd1', 'command 1'], ['cmd2', 'command 2']]
      mock_ssh = mock('Ssh')
      mock_ssh.should_receive(:exec!).with 'command 1'
      mock_ssh.should_receive(:exec!).with 'command 2'
      run_commands mock_ssh
    end

    it 'should run upload command' do
      @commands = [['cmd1', ['from', 'to']]]
      @host = 'host'
      mock_ssh = mock('Ssh')
      mock_scp = mock('Scp')
      Net::SCP.should_receive(:start).with('host', 'root', :password => TEMP_PASSWORD).and_yield mock_scp
      mock_scp.should_receive(:upload!).with 'from', 'to'
      run_commands mock_ssh
    end

    it 'should raise errors when command or name is missing' do
      @commands = [[nil, 'command']]
      lambda{run_commands}.should raise_error(ArgumentError)
      @commands = [['cmd', nil]]
      lambda{run_commands}.should raise_error(ArgumentError)
    end
  end

  describe 'enable_root_login' do
    it 'should set the root password ' do
      mock_ssh = mock('Ssh')
      @host = 'host'
      Net::SSH.should_receive(:start).with('host', DEFAULT_IDENTITY, :password => DEFAULT_IDENTITY).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with "echo #{TEMP_PASSWORD} | sudo -S usermod -p #{TEMP_PASSWORD_ENCRYPTED} root"
      mock_ssh.should_receive(:exec!).with "passwd #{DEFAULT_IDENTITY} -d"
      enable_root_login
    end
  end

  describe 'disable_root_login' do
    it 'should remove the root password on the remote machine' do
      mock_ssh = mock('Ssh')
      @host = 'host'
      Net::SSH.should_receive(:start).with('host', 'root', :password => 'ubuntu').and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with 'passwd -d root'
      disable_root_login
    end
  end

  describe 'display' do
    before(:each) do
      @passwords = {:some_app => 'password'}
    end

    it 'should remove newlines' do
      display("multi\nline\ncommand").should == 'multi\line\command'
    end

    it 'should remove passwords' do
      display("multi\nline\ncommand with password").should == 'multi\line\command with ***'
    end

    it 'should flatten arrays' do
      display(['multi', 'command', 'array']).should == 'multi command array'
    end

    it 'should ignore empty password list' do
      @passwords = {}
      display('something nice').should == 'something nice'
    end
  end

  describe 'required_options' do
    it do
      lambda{required_options({:required => :option}, [:required])}.should_not raise_error(ArgumentError)
    end

    it do
      lambda{required_options({}, [:required])}.should raise_error(ArgumentError)
    end
  end

  describe 'add' do
    it 'should add a command to the commands array and include the caller method name' do
      add_command.should == [['add_command', 'command']]
    end

    def add_command
      add 'command'
      @commands
    end
  end
end

describe 'log' do
  it 'should output messages to the console' do
    should_receive(:puts).with 'message'
    log 'message'
  end
end


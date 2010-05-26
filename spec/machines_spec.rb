require 'spec_helper'

describe 'Machines' do
  before(:each) do
    @commands = []
    @machines = Machines::Base.new(:config => 'config', :userpass => 'password', :host => 'host')
    @machines.stub!(:print)
    @machines.stub!(:puts)
    @ssh_params = {:keys => ['keyfile'], :user_known_hosts_file => %w(/dev/null), :paranoid => false}
    @mock_ssh = mock('Ssh')
  end

  describe 'new' do
    it 'should raise errors' do
      lambda{Machines::Base.new({})}.should raise_error('Password not set')
    end
  end

  describe 'dryrun and install' do
    it "should output the commands to be run" do
      @machines.should_receive(:discover_users)
      @machines.should_receive(:load_machinesfile)
      @machines.should_receive(:run_commands)
      @machines.dryrun
    end
  end

  describe 'install' do
    it 'should run commands in install mode' do
      @machines.should_receive(:discover_users)
      @machines.should_receive(:load_machinesfile)
      @machines.should_receive(:enable_root_login)
      Net::SSH.should_receive(:start).with('host', 'root', @ssh_params).and_yield @mock_ssh
      @machines.should_receive(:run_commands).with @mock_ssh
      @machines.should_receive(:disable_root_login)

      @machines.install
    end
  end

  describe 'discover_users' do
    before(:each) do
      Dir.stub!(:[]).and_return ['users/first', 'users/another']
      @machines.stub!(:load_machinesfile)
    end

    it 'should find users through folder list when called by test' do
      @machines.dryrun
      @machines.users.should == ['first', 'another']
    end

    it 'should find users through folder list when called by install' do
      @machines.dryrun
      @machines.users.should == ['first', 'another']
    end
  end

  describe 'run_commands' do
    before(:each) do
      @machines.stub!(:log_to)
      @machines.stub!(:log_result_to_file)
      @machines.stub!(:load_machinesfile)
      @machines.stub!(:enable_root_login)
      @machines.stub!(:disable_root_login)

      Net::SSH.stub!(:start).with('host', 'root', @ssh_params).and_yield @mock_ssh
    end

    it 'should display all commands queued in the @commands array' do
      @machines.add 'command 1', nil
      @machines.add 'command 2', nil
      @machines.should_receive(:log_to).with(:screen, ')    command 1')
      @machines.should_receive(:log_to).with(:screen, ')    command 2')
      @machines.dryrun
    end

    it 'should run all commands queued in the @commands array with check' do
      @machines.add 'command 1', 'check1'
      @machines.add 'command 2', 'check2'
      @mock_ssh.should_receive(:exec!).with('command 1').and_return ''
      @mock_ssh.should_receive(:exec!).with('check1').and_return ''
      @mock_ssh.should_receive(:exec!).with('command 2').and_return ''
      @mock_ssh.should_receive(:exec!).with('check2').and_return ''
      @machines.install
    end

    it 'should run upload command' do
      @machines.add ['from', 'to'], 'check1'
      @mock_ssh.should_receive(:exec!).with('check1').and_return ''
      mock_scp = mock('Scp')

      Net::SCP.should_receive(:start).with('host', 'root', @ssh_params).and_yield mock_scp
      mock_scp.should_receive(:upload!).with 'from', 'to'
      @machines.install
    end

    it "should catch SCP errors and display message" do
      @machines.add ['from/path', 'to/path'], 'check1'
      @mock_ssh.stub!(:exec!)
      mock_scp = mock('Scp')
      mock_scp.should_receive(:upload!).and_raise 'an error'
      Net::SCP.should_receive(:start).with('host', 'root', @ssh_params).and_yield mock_scp
      @machines.should_receive(:log_to).with(:file, "FAILED\n\n")
      @machines.install
    end
  end

  describe 'enable/disable_root_login' do
    before(:each) do
      @machines.should_receive(:discover_users)
      @machines.should_receive(:load_machinesfile)
      Net::SSH.should_receive(:start).with('host', 'root', @ssh_params).and_yield @mock_ssh
      @machines.should_receive(:run_commands).with @mock_ssh

    end

    it 'should set the root password ' do
      @machines.stub!(:disable_root_login)
      mock_ssh = mock 'Ssh for root'
      Net::SSH.should_receive(:start).with('host', Machines::DEFAULT_IDENTITY, {:password => Machines::DEFAULT_IDENTITY, :user_known_hosts_file => %w(/dev/null), :paranoid => false}).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with "echo #{Machines::TEMP_PASSWORD} | sudo -S usermod -p #{Machines::TEMP_PASSWORD_ENCRYPTED} root"
      @machines.install
    end

    it 'should lock the root login on the remote machine' do
      @machines.stub!(:enable_root_login)
      mock_ssh = mock 'Ssh for root'
      Net::SSH.should_receive(:start).with('host', 'root', @ssh_params.merge(:password => 'ubuntu')).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with 'passwd -l root'
      @machines.install
    end
  end

end


require 'spec_helper'

describe 'Machines' do

  before(:each) do
    @machines = Machines::Base.new
    @machines.stub(:load).with("#{AppConf.project_dir}/Machinesfile")
  end

  describe 'build' do
    it 'raises LoadError with custom message when no Machinesfile' do
      @machines.should_receive(:load).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError.new('Machinesfile not found')

      begin
        @machines.build
      rescue LoadError => e
        e.message.should == 'Machinesfile does not exist. Use `machines generate` to create a template.'
      end
    end

    it 'raises normal LoadError when other file' do
      @machines.should_receive(:load).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError

      begin
        @machines.build
      rescue LoadError => e
        e.message.should == 'LoadError'
      end
    end
  end

=begin
  before(:each) do
    AppConf.commands = []
    @machines = Machines::Base.new
    AppConf.machine = 'config'
    AppConf.hostname = 'host'
    AppConf.user = {:name => 'user', :pass => 'pass'}
    @machines.stub(:print)
    @machines.stub(:puts)
    @mock_ssh = mock('Ssh')
    Net::SSH.stub(:start)
  end

  describe 'dryrun and setup' do
    it "should output the commands to be run" do
      @machines.should_receive(:load_machinesfile)
      @machines.should_receive(:run_commands)
      @machines.dryrun
    end
  end

  describe 'setup' do
    it 'should run commands in setup mode' do
      @machines.should_receive(:load_machinesfile)
      @machines.should_receive(:enable_root_login)
      Net::SSH.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield @mock_ssh
      @machines.should_receive(:run_commands).with @mock_ssh
      @machines.should_receive(:disable_root_login)

      @machines.setup
    end
  end

  describe 'discover_users' do
    before(:each) do
      Dir.stub(:[]).and_return ['users/first', 'users/another']
      @machines.stub(:load_machinesfile)
    end

    it 'should find users through folder list when called by test' do
      @machines.dryrun
      @machines.users.should == ['first', 'another']
    end

    it 'should find users through folder list when called by setup' do
      @machines.should_receive(:enable_root_login)
      Net::SSH.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield @mock_ssh
      @machines.should_receive(:run_commands).with @mock_ssh
      @machines.should_receive(:disable_root_login)
      @machines.setup
      @machines.users.should == ['first', 'another']
    end
  end

  describe 'run_commands' do
    before(:each) do
      @machines.stub(:log_to)
      @machines.stub(:log_result_to_file)
      @machines.stub(:load_machinesfile)
      @machines.stub(:enable_root_login)
      @machines.stub(:disable_root_login)

      Net::SSH.stub(:start).with('host', 'root', :keys => ['keyfile']).and_yield @mock_ssh
    end

    it 'should display all commands queued in the AppConf.commands array' do
      @machines.add 'command 1', nil
      @machines.add 'command 2', nil
      @machines.should_receive(:log_to).with(:screen, ':      command 1')
      @machines.should_receive(:log_to).with(:screen, ':      command 2')
      @machines.dryrun
    end

    it 'should run all commands queued in the AppConf.commands array with check' do
      @machines.add 'command 1', 'check1'
      @machines.add 'command 2', 'check2'
      @mock_ssh.should_receive(:exec!).with('command 1').and_return ''
      @mock_ssh.should_receive(:exec!).with('check1').and_return ''
      @mock_ssh.should_receive(:exec!).with('command 2').and_return ''
      @mock_ssh.should_receive(:exec!).with('check2').and_return ''
      @machines.setup
    end

    it 'should run upload command' do
      @machines.add ['from', 'to'], 'check1'
      @mock_ssh.should_receive(:exec!).with('check1').and_return ''
      mock_scp = mock('Scp')

      Net::SCP.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield mock_scp
      mock_scp.should_receive(:upload!).with 'from', 'to'
      @machines.setup
    end

    it "should catch SCP errors and display message" do
      @machines.add ['from/path', 'to/path'], 'check1'
      @mock_ssh.stub(:exec!)
      mock_scp = mock('Scp')
      mock_scp.should_receive(:upload!).and_raise 'an error'
      Net::SCP.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield mock_scp
      @machines.should_receive(:log_to).with(:file, "FAILED\n\n")
      @machines.setup
    end
  end

  describe 'enable/disable_root_login' do
    before(:each) do
      @machines.should_receive(:load_machinesfile)
      Net::SSH.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield @mock_ssh
      @machines.should_receive(:run_commands).with @mock_ssh

    end

    it 'should enable root login' do
      @machines.stub(:disable_root_login)
      mock_ssh = mock 'Ssh for root'
      Net::SSH.should_receive(:start).with('host', AppConf.user.name, {:keys => ['keyfile']}).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with "sudo sh -c 'test -f /root/.ssh/authorized_keys && mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.orig || mkdir /root/.ssh'"
      mock_ssh.should_receive(:exec!).with "sudo sh -c 'cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/'"
      @machines.setup
    end

    it 'should lock the root login on the remote machine' do
      @machines.stub(:enable_root_login)
      mock_ssh = mock 'Ssh for root'
      Net::SSH.should_receive(:start).with('host', 'root', :keys => ['keyfile']).and_yield(mock_ssh)
      mock_ssh.should_receive(:exec!).with 'rm /root/.ssh/authorized_keys'
      mock_ssh.should_receive(:exec!).with 'test -f /root/.ssh/authorized_keys.orig && mv /root/.ssh/authorized_keys.orig /root/.ssh/authorized_keys'
      @machines.setup
    end
  end
=end
end


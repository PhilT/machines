require 'spec_helper'

describe 'Machines' do
  include Core

  subject {Machines::Base.new}

  before(:each) do
    File.stub(:read).and_return ''
    AppConf.ec2 = AppConf.new unless AppConf.ec2
    AppConf.ec2.use = nil
    AppConf.log_only = false
    FileUtils.mkdir_p '/prj/config'
    File.open('/prj/config/config.yml', 'w') { |f| f.puts "timezone: GB" }
  end

  describe 'init' do
    it 'initializes some AppConf settings and loads configs' do
      subject.init
      AppConf.machines.should == {}
      AppConf.passwords.should == []
      AppConf.commands.should == []
      AppConf.apps.should == {}
      AppConf.tasks.should == {}
      AppConf.user.should be_a AppConf
      AppConf.db.should be_a AppConf
      AppConf.timezone.should == 'GB'
      AppConf.log_path.should == '/prj/log/output.log'
      File.should exist '/prj/log/output.log'
      AppConf.log.should be_a File
    end
  end

  describe 'dryrun' do
    it 'asks build to only log commands' do
      subject.should_receive(:build)
      subject.dryrun
      AppConf.log_only.should be_true
    end
  end

  describe 'build' do
    before(:each) do
      subject.stub(:init)
      AppConf.target_address = 'target'
      AppConf.user.name = 'username'
      AppConf.user.pass = 'userpass'
    end

    it 'raises LoadError with custom message when no Machinesfile' do
      File.should_receive(:read).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError.new('Machinesfile not found')

      begin
        subject.build
      rescue LoadError => e
        e.message.should == 'Machinesfile does not exist. Use `machines new <DIR>` to create a template.'
      end
    end

    it 'raises normal LoadError on other files' do
      File.should_receive(:read).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError

      begin
        subject.build
      rescue LoadError => e
        e.message.should == 'LoadError'
      end
    end

    it 'starts an SCP session using password authentication' do
      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass')
      subject.build
    end

    it 'starts an SCP session using key based authentication' do
      AppConf.ec2.use = true
      AppConf.ec2.private_key_file = 'private_key_file'
      Net::SCP.should_receive(:start).with('target', 'ubuntu', :keys => ['private_key_file'])

      subject.build
    end

    it 'runs each command' do
      mock_command = mock Command
      AppConf.commands = [mock_command]
      mock_scp = mock Net::SCP, :session => nil

      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass').and_yield(mock_scp)
      Command.should_receive(:scp=).with(mock_scp)
      mock_command.should_receive(:run)

      subject.build
    end

    it 'runs single task when supplied' do
      mock_scp = mock Net::SCP, :session => nil
      Net::SCP.stub(:start).and_yield(mock_scp)
      AppConf.commands = [mock(Command)]
      AppConf.commands.first.should_not_receive(:run)
      mock_command_from_task = Command.new 'command', 'check'
      mock_command_from_task.should_receive(:run)
      AppConf.tasks = { :task => {:block => Proc.new { run mock_command_from_task }} }

      subject.build 'task'
    end

    it 'logs instead of SSHing and running commands' do
      Net::SCP.should_not_receive(:start)
      AppConf.commands = [mock(Command)]
      AppConf.commands.first.should_receive(:run)
      AppConf.log_only = true
      subject.build
    end
  end
end


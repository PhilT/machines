require 'spec_helper'

describe 'Machines' do
  subject {Machines::Base.new}

  before(:each) do
    File.stub(:read).and_return ''
    AppConf.log_only = false
    File.open('config.yml', 'w') { |f| f.puts "timezone: GB" }
    FileUtils.mkdir 'log'
  end

  describe 'init' do
    it 'initializes some AppConf settings and loads configs' do
      Command.file = nil
      Command.console = nil
      Command.debug = nil
      subject.init
      AppConf.passwords.should == []
      AppConf.commands.should == []
      AppConf.webapps.should == {}
      AppConf.tasks.should == {}
      AppConf.timezone.should == 'GB'
      File.should exist 'log/output.log'
      Command.file.should be_a Machines::Logger
      Command.console.should be_a Machines::Logger
      Command.debug.should be_a Machines::Logger
    end
  end

  describe 'load_machinesfile' do
    it 'raises LoadError with custom message when no Machinesfile' do
      File.should_receive(:read).with("Machinesfile").and_raise LoadError.new('Machinesfile not found')

      begin
        subject.load_machinesfile
      rescue LoadError => e
        e.message.should == 'Machinesfile does not exist. Use `machines new <DIR>` to create a template.'
      end
    end

    it 'raises normal LoadError on other files' do
      File.should_receive(:read).with("Machinesfile").and_raise LoadError

      begin
        subject.load_machinesfile
      rescue LoadError => e
        e.message.should == 'LoadError'
      end
    end
  end

  describe 'tasks' do
    it 'displays a list of tasks' do
      subject.should_receive(:init)
      subject.should_receive(:load_machinesfile)
      AppConf.tasks = {
        :task1 => {:description => 'description 1'},
        :task2 =>  {:description => 'description 2'},
        :task3 => {:description => 'description 3'}
      }
      subject.tasks
      $output.should == 'Tasks
  task1                description 1
  task2                description 2
  task3                description 3
'
    end
  end

  describe 'dryrun' do
    it 'asks build to only log commands' do
      options = []
      subject.should_receive(:build).with options
      subject.dryrun options
      AppConf.log_only.should be_true
    end
  end

  describe 'build' do
    before(:each) do
      subject.stub(:init)
      AppConf.machine = AppConf.new
      AppConf.address = 'target'
      AppConf.user = 'username'
      AppConf.password = 'userpass'
    end

    it 'sets machine_name' do
      Net::SCP.stub(:start)
      subject.build ['machine']
      AppConf.machine_name.should == 'machine'
    end

    it 'starts an SCP session using password authentication' do
      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass')
      subject.build []
    end

    it 'starts an SCP session using key based authentication' do
      AppConf.machine.cloud = AppConf.new
      AppConf.machine.cloud.private_key_path = 'path/to/private_key'
      AppConf.machine.cloud.username = 'ubuntu'
      Net::SCP.should_receive(:start).with('target', 'ubuntu', :keys => ['path/to/private_key'])

      subject.build []
    end

    it 'runs each command' do
      mock_command = mock Command
      AppConf.commands = [mock_command]
      mock_scp = mock Net::SCP, :session => nil

      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass').and_yield(mock_scp)
      Command.should_receive(:scp=).with(mock_scp)
      mock_command.should_receive(:run)

      subject.build []
    end

    it 'flushes log file after running command' do
      AppConf.log_only = false
      mock_command = mock Command
      AppConf.commands = [mock_command]
      mock_scp = mock Net::SCP, :session => nil

      Net::SCP.stub(:start).and_yield(mock_scp)
      Command.stub(:scp=)
      mock_command.stub(:run)
      Command.file.should_receive(:flush)
      subject.build []
    end

    it 'runs single task when supplied' do
      mock_scp = mock Net::SCP, :session => nil
      Net::SCP.stub(:start).and_yield(mock_scp)
      AppConf.commands = [mock(Command)]
      AppConf.commands.first.should_not_receive(:run)
      mock_command_from_task = Command.new 'command', 'check'
      mock_command_from_task.should_receive(:run)
      AppConf.tasks = { :task => {:block => Proc.new { run mock_command_from_task }} }

      subject.build ['machine', 'task']
    end

    it 'logs instead of SSHing and running commands' do
      Net::SCP.should_not_receive(:start)
      AppConf.commands = [mock(Command)]
      AppConf.commands.first.should_receive(:run)
      AppConf.log_only = true
      subject.build []
    end

    describe 'interrupts' do
      before(:each) do
        mock_command = mock Command
        AppConf.commands = [mock_command]
        mock_scp = mock Net::SCP, :session => nil

        Net::SCP.stub(:start).with('target', 'username', :password => 'userpass').and_yield(mock_scp)
        mock_command.stub(:run)
      end

      it 'handles CTRL+C and calls handler' do
        subject.should_receive(:prepare_to_exit)
        Kernel.should_receive(:trap).with('INT').and_yield
        subject.build []
      end

      it 'sets exit flag and displays message' do
        subject.prepare_to_exit
        $exit_requested.should be_true
        "\nEXITING after current command completes...\n".should be_displayed as_warning
      end

      it 'second request to exit exits immediately' do
        $exit_requested = true
        subject.should_receive(:exit)
        subject.prepare_to_exit
      end

      it 'exits when exit requested' do
        $exit_requested = true
        subject.should_receive(:exit)

        subject.build []
      end
    end
  end
end


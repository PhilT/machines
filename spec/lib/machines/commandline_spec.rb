require 'spec_helper'

describe Machines::Commandline do
  include Machines::Core
  include Machines::Commandline
  include Machines::Questions

  before(:each) do
    $conf.log_only = false
    File.open('config.yml', 'w') { |f| f.puts "timezone: GB" }
    FileUtils.mkdir_p 'log'
  end

  describe 'build' do
    before(:each) do
      stubs(:init)
      File.stubs(:read).returns ''
      $conf.machine = AppConf.new
      $conf.address = 'target'
      $conf.user = 'username'
      $conf.password = 'userpass'
    end

    it 'sets machine_name' do
      Net::SCP.stubs(:start)
      build ['machine']
      $conf.machine_name.must_equal 'machine'
    end

    it 'starts an SCP session using password authentication' do
      Net::SCP.expects(:start).with('target', 'username', :password => 'userpass')
      build []
    end

    it 'starts an SCP session using key based authentication' do
      $conf.machine.cloud = AppConf.new
      $conf.machine.cloud.private_key_path = 'path/to/private_key'
      $conf.machine.cloud.username = 'ubuntu'
      Net::SCP.expects(:start).with('target', 'ubuntu', :keys => ['path/to/private_key'])

      build []
    end

    it 'runs each command' do
      mock_command = mock 'Machines::Command'
      $conf.commands = [mock_command]
      mock_scp = stub 'Net::SCP', :session => nil

      Net::SCP.expects(:start).with('target', 'username', :password => 'userpass').yields(mock_scp)
      Machines::Command.expects(:scp=).with(mock_scp)
      mock_command.expects(:run)

      build []
    end

    it 'flushes log file after running command' do
      $conf.log_only = false
      mock_command = mock 'Machines::Command'
      $conf.commands = [mock_command]
      mock_scp = stub 'Net::SCP', :session => nil

      Net::SCP.stubs(:start).yields(mock_scp)
      Machines::Command.stubs(:scp=)
      mock_command.stubs(:run)
      Machines::Command.file.expects(:flush)
      build []
    end

    it 'runs single task when supplied' do
      mock_scp = mock 'Net::SCP', :session => nil
      Net::SCP.stubs(:start).yields(mock_scp)
      $conf.commands = [mock('Machines::Command')]
      $conf.commands.first.expects(:run).never
      mock_command_from_task = Machines::Command.new 'command', 'check'
      mock_command_from_task.expects(:run)
      $conf.tasks = { :task => {:block => Proc.new { run mock_command_from_task }} }

      build ['machine', 'task']
    end

    it 'logs instead of SSHing and running commands' do
      Net::SCP.expects(:start).never
      $conf.commands = [mock('Machines::Command')]
      $conf.commands.first.expects(:run)
      $conf.log_only = true
      build []
    end

    describe 'interrupts' do
      before(:each) do
        mock_command = mock 'Machines::Command'
        $conf.commands = [mock_command]
        mock_scp = stub 'Net::SCP', :session => nil

        Net::SCP.stubs(:start).with('target', 'username', :password => 'userpass').yields(mock_scp)
        mock_command.stubs(:run)
        $exit_requested = false
      end

      it 'handles CTRL+C and calls handler' do
        expects(:prepare_to_exit)
        Kernel.expects(:trap).with('INT').yields
        build []
      end


      it 'sets exit flag and displays message' do
        prepare_to_exit
        $exit_requested.must_equal true
        $console.next.must_equal colored("\nEXITING after current command completes...\n", :warning)
      end

      it 'second request to exit exits immediately' do
        $exit_requested = true
        expects(:exit)
        prepare_to_exit
      end

      it 'exits when exit requested' do
        $exit_requested = true
        expects(:exit)

        build []
      end
    end
  end

  describe 'dryrun' do
    it 'asks build to only log commands' do
      options = []
      expects(:build).with options
      dryrun options
      $conf.log_only.must_equal true
    end
  end

  describe 'execute' do
    it 'calls specified action' do
      %w(htpasswd dryrun build).each do |action|
        expects action
        execute [action]
      end
    end

    it 'calls generate with folder' do
      expects(:generate).with(['dir'])
      execute ['new', 'dir']
    end

    it 'calls generate without folder' do
      expects(:generate).with([])
      execute ['new']
    end

    it 'calls help when no matching command' do
      lambda { execute ['anything'] }.must_output Machines::Help.new.syntax
    end
  end

  describe 'generate' do
    it 'copies the template within ./' do
      expects(:ask).with("Overwrite './' (y/n)? ").returns 'y'
      FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", './')
      FileUtils.expects(:mkdir_p).with('./packages')
      generate []
    end

    it 'copies the template within dir' do
      FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", 'dir')
      FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
      expects(:say).with('Project created at dir/')
      generate ['dir']
    end

    describe 'when folder exists' do
      before(:each) do
        FileUtils.mkdir_p('dir')
      end

      it 'is overwritten after user confirmation' do
        expects(:ask).with("Overwrite 'dir' (y/n)? ").returns 'y'
        FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", 'dir')
        FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
        generate ['dir']
      end

      it 'generation is aborted at user request' do
        expects(:ask).with("Overwrite 'dir' (y/n)? ").returns 'n'
        FileUtils.expects(:cp_r).never
        FileUtils.expects(:mkdir_p).never
        generate ['dir']
      end
    end
  end

  describe 'htpasswd' do
    it 'htpasswd is generated and saved' do
      $conf.webserver = 'server'
      $input.string = "user\npass\npass\n"
      htpasswd nil
      File.read('server/conf/htpasswd').must_match /user:.{13}/
    end
  end

  describe 'init' do
    it 'initializes some $conf settings and loads configs' do
      Machines::Command.file = nil
      Machines::Command.console = nil
      Machines::Command.debug = nil
      init
      $conf.passwords.must_equal []
      $conf.commands.must_equal []
      $conf.webapps.must_equal({})
      $conf.tasks.must_equal({})
      $conf.timezone.must_equal 'GB'
      File.exists?('log/output.log').must_equal true
      Machines::Command.file.must_be_instance_of Machines::Logger
      Machines::Command.console.must_be_instance_of Machines::Logger
      Machines::Command.debug.must_be_instance_of Machines::Logger
    end
  end

  describe 'load_machinesfile' do
    it 'raises LoadError with custom message when no Machinesfile' do
      File.expects(:read).with("Machinesfile").raises LoadError.new('Machinesfile not found')

      begin
        load_machinesfile
      rescue LoadError => e
        e.message.must_equal 'Machinesfile does not exist. Use `machines new <DIR>` to create a template.'
      end
    end

    it 'raises normal LoadError on other files' do
      File.expects(:read).with("Machinesfile").raises LoadError

      begin
        load_machinesfile
      rescue LoadError => e
        e.message.must_equal 'LoadError'
      end
    end
  end

  describe 'override' do
    before(:each) do
      FileUtils.mkdir_p File.join($conf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join($conf.application_dir, 'packages', 'base.rb')
    end

    it 'copies package to project folder' do
      override 'base'
      File.exists?('packages/base.rb').must_equal true
    end

    describe 'when copying over existing package' do
      before(:each) do
        FileUtils.touch 'packages/base.rb'
      end

      it 'terminates when user answer no' do
        $input.string = "n\n"
        lambda { override 'base' }.must_output 'Project package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.string = "y\n"
        lambda { override 'base' }.must_output 'Project package already exists. Overwrite? (y/n)
Package copied to packages/base.rb
'
      end
    end
  end

  describe 'packages' do
    it 'displays a list of default and project packages' do
      FileUtils.mkdir_p File.join($conf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join($conf.application_dir, 'packages', 'base.rb')
      FileUtils.touch File.join('packages', 'apps.rb')
      lambda { packages }.must_output 'Default packages
 * base
Project packages
 * apps
'
    end
  end

  describe 'tasks' do
    it 'displays a list of tasks' do
      expects(:init)
      expects(:load_machinesfile)
      $conf.tasks = {
        :task1 => {:description => 'description 1'},
        :task2 =>  {:description => 'description 2'},
        :task3 => {:description => 'description 3'}
      }
      lambda { tasks }.must_output 'Tasks
  task1                description 1
  task2                description 2
  task3                description 3
'
    end
  end
end


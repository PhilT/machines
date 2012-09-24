require 'spec_helper'

describe Machines::Commandline do
  include Machines::Core
  include Machines::Commandline
  include Machines::Questions

  before(:each) do
    $conf.log_only = false
    File.open('config.yml', 'w') {|f| f.puts "timezone: GB" }
    FileUtils.mkdir_p 'log'
  end

  describe 'build' do
    before(:each) do
      stubs(:init)
      FileUtils.touch('Machinesfile')
      $conf.machine = AppConf.new
      $conf.machine.address = 'target'
      $conf.machine.user = 'username'
      $conf.password = 'userpass'
      Net::SCP.stubs(:new)
      @ssh_stub = stub('Net::SSH', :close => nil, :exec! => nil)
      Net::SSH.stubs(:start).returns @ssh_stub
    end

    it 'displays syntax when no machine name specified' do
      lambda { build [] }.must_output Machines::Help.new.syntax
    end

    it 'sets machine_name' do
      build ['machine']
      $conf.machine_name.must_equal 'machine'
    end

    it 'starts an SCP session using password authentication' do
      options = {paranoid: false, password: 'userpass'}
      Net::SSH.expects(:start).with('target', 'username', options).returns @ssh_stub
      build ['machine']
    end

    it 'starts an SCP session using key based authentication' do
      $conf.machine.cloud = AppConf.new
      $conf.machine.cloud.private_key_path = 'path/to/private_key'
      $conf.machine.cloud.username = 'ubuntu'
      options = {paranoid: false, keys: ['path/to/private_key']}
      Net::SSH.expects(:start).with('target', 'ubuntu', options).returns @ssh_stub

      build ['machine']
    end

    it 'runs each command' do
      mock_command = mock 'Machines::Command'
      $conf.commands = [mock_command]

      mock_command.expects(:run)

      build ['machine']
    end

    it 'flushes log file after running command' do
      $conf.log_only = false
      command_stub = stub('Machines::Command', :run => nil)
      $conf.commands = [command_stub]

      Machines::Command.file.expects(:flush)
      build ['machine']
    end

    it 'only run specified tasks' do
      command_will_run = Machines::Command.new '', ''
      command_also_run = Machines::Command.new '', ''
      command_wont_run = Machines::Command.new '', ''
      $conf.tasks = { 
        :task1 => {:block => Proc.new { run command_will_run }},
        :task2 => {:block => Proc.new { run command_also_run }}
      }

      build ['machine', 'task1', 'task2']

      $conf.commands.must_equal [command_will_run, command_also_run]
    end

    it 'logs instead of SSHing and running commands' do
      Net::SCP.expects(:start).never
      $conf.commands = [mock('Machines::Command')]
      $conf.commands.first.expects(:run)
      $conf.log_only = true
      build ['machine']
    end

    describe 'interrupts' do
      before(:each) do
        mock_command = mock 'Machines::Command'
        $conf.commands = [mock_command]

        mock_command.stubs(:run)
        $exit_requested = false
      end

      it 'handles CTRL+C and calls handler' do
        expects(:prepare_to_exit)
        Kernel.expects(:trap).with('INT').yields
        build ['machine']
      end


      it 'sets exit flag and displays message' do
        prepare_to_exit
        $exit_requested.must_equal true
        message = "\nEXITING after current command completes...\n"
        $console.next.must_equal colored(message, :warning)
      end

      it 'second request to exit exits immediately' do
        $exit_requested = true
        expects(:exit)
        prepare_to_exit
      end

      it 'exits when exit requested' do
        $exit_requested = true
        expects(:exit)

        build ['machine']
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

    it 'passes tasks to build' do
      options = ['machine', 'task']
      expects(:build).with options
      dryrun options
    end
  end

  describe 'execute' do
    it 'calls specified action' do
      Machines::Help.new.actions.reject{|a| a == 'new'}.each do |action|
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
      File.read('server/htpasswd').must_match /user:.{13}/
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
      $conf.tasks.must_equal({})
      $conf.timezone.must_equal 'GB'
      File.exists?('log/output.log').must_equal true
      Machines::Command.file.must_be_instance_of Machines::Logger
      Machines::Command.console.must_be_instance_of Machines::Logger
      Machines::Command.debug.must_be_instance_of Machines::Logger
    end
  end

  describe 'list' do
    it 'lists machines' do
      File.open('machines.yml', 'w') {|f| f.puts({'machines' => {'machine_1' => {}, 'machine_2' => {}}}.to_yaml) }
      lambda { list [] }.must_output "Machines from machines.yml:\n  machine_1\n  machine_2\n"
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
      override ['base']
      File.exists?('packages/base.rb').must_equal true
    end

    describe 'when copying over existing package' do
      before(:each) do
        FileUtils.touch 'packages/base.rb'
      end

      it 'terminates when user answer no' do
        $input.string = "n\n"
        lambda { override ['base'] }.must_output 'Project package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.string = "y\n"
        lambda { override ['base'] }.must_output 'Project package already exists. Overwrite? (y/n)
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
      lambda { packages nil }.must_output 'Default packages
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


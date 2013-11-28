require 'spec_helper'

describe Commandline do

  subject { Commandline.new }

  before do
    subject
    Commandline.stubs(:new).returns subject
    $conf.log_only = false
    File.open('config.yml', 'w') {|f| f.puts "timezone: GB" }
    FileUtils.mkdir_p 'log'
  end

  describe 'build' do
    before do
      subject.stubs(:init)
      FileUtils.touch('Machinesfile')
      $conf.machine = AppConf.new
      $conf.machine.address = 'target'
      $conf.machine.user = 'username'
      $passwords.password = 'userpass'
      Net::SCP.stubs(:new)
      @ssh_stub = stub('Net::SSH', :close => nil, :exec! => nil)
    end

    it 'displays syntax when no machine name specified' do
      lambda { subject.build [] }.must_output Help.new.syntax
    end

    it 'logs instead of SSHing and running commands' do
      Net::SCP.expects(:start).never
      $conf.commands = [mock('command')]
      $conf.commands.first.expects(:run)
      $conf.log_only = true
      subject.build ['machine']
    end

    describe 'when connected' do
      before do
        Net::SSH.stubs(:start).returns @ssh_stub
      end

      it 'sets machine_name' do
        subject.build ['machine']
        $conf.machine_name.must_equal 'machine'
      end

      it 'runs each command' do
        mock_command = mock 'Command'
        $conf.commands = [mock_command]

        mock_command.expects(:run)

        subject.build ['machine']
      end

      it 'flushes log file after running command' do
        $conf.log_only = false
        command_stub = stub('command', :run => nil)
        $conf.commands = [command_stub]

        Command.file.expects(:flush)
        subject.build ['machine']
      end

      it 'only run specified tasks' do
        command_will_run = Command.new 'will run', ''
        command_also_run = Command.new 'also run', ''
        command_wont_run = Command.new 'wont run', ''
        $conf.tasks = {
          :task1 => {:block => lambda { $conf.commands << command_will_run }},
          :task2 => {:block => lambda { $conf.commands << command_also_run }},
          :task3 => {:block => lambda { $conf.commands << command_wont_run }}
        }

        subject.build ['machine', 'task1', 'task2']

        $conf.commands.must_equal [command_will_run, command_also_run]
      end

      it 'starts an SCP session using password authentication' do
        options = {paranoid: false, password: 'userpass'}
        Net::SSH.expects(:start).with('target', 'username', options).returns @ssh_stub
        subject.build ['machine']
      end

      it 'starts an SCP session using key based authentication' do
        $conf.machine.cloud = AppConf.new
        $conf.machine.cloud.private_key_path = 'path/to/private_key'
        $conf.machine.cloud.username = 'ubuntu'
        options = {paranoid: false, keys: ['path/to/private_key']}
        Net::SSH.expects(:start).with('target', 'ubuntu', options).returns @ssh_stub

        subject.build ['machine']
      end
    end

    describe 'when not connected' do
      it 'handles timeout errors' do
        Net::SSH.expects(:start).raises Errno::ETIMEDOUT
        proc { subject.build ['machine'] }.must_output /Connection timed out.*Check the IP address in machines.yml/m
      end

      it 'SSH connection not closed when no connection previously established' do
        Net::SSH.expects(:start).returns nil
        subject.build ['machine']
      end

      it 'ensures SSH connection closed when error' do
        Net::SSH.expects(:start).returns @ssh_stub
        Net::SCP.expects(:new).raises Errno::ETIMEDOUT
        @ssh_stub.expects(:close)
        subject.build ['machine']
      end
    end

    describe 'interrupts' do
      before do
        mock_command = mock 'command'
        $conf.commands = [mock_command]

        mock_command.stubs(:run)
        $exit_requested = false
        Net::SSH.stubs(:start).returns @ssh_stub
      end

      it 'handles CTRL+C and calls handler' do
        subject.expects(:prepare_to_exit)
        Kernel.expects(:trap).with('INT').yields
        subject.build ['machine']
      end

      it 'sets exit flag and displays message' do
        subject.send :prepare_to_exit
        $exit_requested.must_equal true
        message = "\nEXITING after current command completes...\n"
        $console.next.must_equal colored(message, :warning)
      end

      it 'second request to exit exits immediately' do
        $exit_requested = true
        subject.expects(:exit)
        subject.send :prepare_to_exit
      end

      it 'exits when exit requested' do
        $exit_requested = true
        subject.expects(:exit)

        subject.build ['machine']
      end
    end
  end

  describe 'dryrun' do
    it 'asks build to only log commands' do
      options = []
      subject.expects(:build).with options
      subject.dryrun options
      $conf.log_only.must_equal true
    end

    it 'passes tasks to build' do
      options = ['machine', 'task']
      subject.expects(:build).with options
      subject.dryrun options
    end
  end

  describe 'execute' do
    it 'calls specified action' do
      Help.new.actions.reject{|a| a == 'new'}.each do |action|
        subject.expects action
        Commandline.execute [action]
      end
    end

    it 'calls generate with folder' do
      subject.expects(:generate).with(['dir'])
      Commandline.execute ['new', 'dir']
    end

    it 'calls generate without folder' do
      subject.expects(:generate).with([])
      Commandline.execute ['new']
    end

    it 'calls help when no matching command' do
      lambda { Commandline.execute ['anything'] }.must_output Help.new.syntax
    end
  end

  describe 'generate' do
    it 'copies the template within ./' do
      subject.expects(:ask).with("Overwrite './' (y/n)? ").returns 'y'
      FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", './')
      FileUtils.expects(:mkdir_p).with('./packages')
      subject.generate []
    end

    it 'copies the template within dir' do
      FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", 'dir')
      FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
      subject.expects(:say).with('Project created at dir/')
      subject.generate ['dir']
    end

    describe 'when folder exists' do
      before do
        FileUtils.mkdir_p('dir')
      end

      it 'is overwritten after user confirmation' do
        subject.expects(:ask).with("Overwrite 'dir' (y/n)? ").returns 'y'
        FileUtils.expects(:cp_r).with("#{$conf.application_dir}/template/.", 'dir')
        FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
        subject.generate ['dir']
      end

      it 'generation is aborted at user request' do
        subject.expects(:ask).with("Overwrite 'dir' (y/n)? ").returns 'n'
        FileUtils.expects(:cp_r).never
        FileUtils.expects(:mkdir_p).never
        subject.generate ['dir']
      end
    end
  end

  describe 'htpasswd' do
    it 'htpasswd is generated and saved' do
      $conf.webserver = 'server'
      $input.string = "user\npass\npass\n"
      subject.htpasswd nil
      File.read('server/htpasswd').must_match /user:.{13}/
    end
  end

  describe 'init' do
    it 'initializes some $conf settings and loads configs' do
      Command.file = nil
      Command.console = nil
      Command.debug = nil
      subject.init
      $passwords.to_filter.must_equal []
      $conf.commands.must_equal []
      $conf.tasks.must_equal({})
      $conf.timezone.must_equal 'GB'
      File.exists?('log/output.log').must_equal true
      Command.file.must_be_instance_of Machines::Logger
      Command.console.must_be_instance_of Machines::Logger
      Command.debug.must_be_instance_of Machines::Logger
    end
  end

  describe 'list' do
    it 'lists machines' do
      File.open('machines.yml', 'w') {|f| f.puts({'machines' => {'machine_1' => {}, 'machine_2' => {}}}.to_yaml) }
      lambda { subject.list nil }.must_output "Machines from machines.yml:\n  machine_1\n  machine_2\n"
    end
  end

  describe 'override' do
    before do
      FileUtils.mkdir_p File.join($conf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join($conf.application_dir, 'packages', 'base.rb')
    end

    it 'copies package to project folder' do
      subject.override ['base']
      File.exists?('packages/base.rb').must_equal true
    end

    describe 'when copying over existing package' do
      before do
        FileUtils.touch 'packages/base.rb'
      end

      it 'terminates when user answer no' do
        $input.string = "n\n"
        lambda { subject.override ['base'] }.must_output 'Project package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.string = "y\n"
        lambda { subject.override ['base'] }.must_output 'Project package already exists. Overwrite? (y/n)
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
      lambda { subject.packages nil }.must_output 'Default packages
 * base
Project packages
 * apps
'
    end
  end

  describe 'tasks' do
    it 'displays a list of tasks' do
      subject.expects(:init)
      Core.any_instance.expects(:package).with 'Machinesfile'
      $conf.tasks = {
        :task1 => {:description => 'description 1'},
        :task2 =>  {:description => 'description 2'},
        :task3 => {:description => 'description 3'}
      }
      lambda { subject.tasks ['machine'] }.must_output 'Tasks
  task1                description 1
  task2                description 2
  task3                description 3
'
      $conf.machine_name.must_equal 'machine'
    end
  end
end


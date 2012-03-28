require './spec/spec_helper'

describe 'Commandline' do
  include Machines::Commandline
  include Machines::Core

  describe 'build' do
    it 'starts an SCP session using password authentication' do
      Net::SCP.expects(:start).with('target', 'username', :password => 'userpass')
      build []
    end

    it 'starts an SCP session using key based authentication' do
      AppConf.machine.cloud = AppConf.new
      AppConf.machine.cloud.private_key_path = 'path/to/private_key'
      AppConf.machine.cloud.username = 'ubuntu'
      Net::SCP.expects(:start).with('target', 'ubuntu', :keys => ['path/to/private_key'])

      build []
    end

    it 'runs each command' do
      mock_command = mock 'Command'
      AppConf.commands = [mock_command]
      mock_scp = mock 'Net::SCP', :session => nil

      Net::SCP.expects(:start).with('target', 'username', :password => 'userpass').yields(mock_scp)
      Machines::Command.expects(:scp=).with(mock_scp)
      mock_command.expects(:run)

      build []
    end

    it 'flushes log file after running command' do
      AppConf.log_only = false
      mock_command = mock 'Command'
      AppConf.commands = [mock_command]
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
      AppConf.commands = [mock('Command')]
      mock_command_from_task = Machines::Command.new 'command', 'check'
      mock_command_from_task.expects(:run)
      AppConf.tasks = { :task => {:block => Proc.new { run mock_command_from_task }} }

      build ['machine', 'task']
    end

    it 'logs instead of SSHing and running commands' do
      AppConf.commands = [mock('Command')]
      AppConf.commands.first.expects(:run)
      AppConf.log_only = true
      build []
    end

    describe 'interrupts' do
      before do
        mock_command = mock 'Command'
        AppConf.commands = [mock_command]
        mock_scp = mock 'Net::SCP', :session => nil

        Net::SCP.stubs(:start).with('target', 'username', :password => 'userpass').yields(mock_scp)
        mock_command.stubs(:run)
      end

      it 'handles CTRL+C and calls handler' do
        expects(:prepare_to_exit)
        Kernel.expects(:trap).with('INT').yields
        build []
      end

      it 'sets exit flag and displays message' do
        prepare_to_exit
        $exit_requested.must_equal true
        "\nEXITING after current command completes...\n".must_be_displayed as_warning
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

  end

  describe 'execute' do

  end
end
=begin


  describe 'execute' do
    let(:mock_help) { mock 'Help' }

    before do
      mock_help.stubs(:actions).returns(['action', 'new'])
    end

    it 'calls specified action when included in help' do
      expects :action
      execute ['action'], mock_help
    end

    it 'calls generate with options' do
      expects(:generate).with(['opt1'])
      execute ['new', 'opt1'], mock_help
    end

    it 'calls help when no matching command' do
      mock_help.stubs(:syntax).returns('help syntax')
      lambda { execute(['anything'], mock_help) }.must_output "help syntax\n"
    end
  end

  describe 'dryrun' do
    it 'asks build to only log commands' do
      options = []
      expects(:build).with options
      dryrun options
      AppConf.log_only.must_equal true
    end
  end

  describe 'generate' do
    it 'copies the template' do
      FileUtils.expects(:cp_r).with("#{AppConf.application_dir}/template/.", '.')
      FileUtils.expects(:mkdir_p).with('./packages')
      generate []
    end

    it 'copies the template within dir' do
      FileUtils.expects(:cp_r).with("#{AppConf.application_dir}/template/.", 'dir')
      FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
      expects(:say).with('Project created at dir/')
      generate ['dir']
    end

    describe 'when folder exists' do
      before do
        FileUtils.mkdir_p('dir')
      end

      it 'is overwritten after user confirmation' do
        expects(:ask).with('Folder already exists. Overwrite (y/n)? ').returns 'y'
        FileUtils.expects(:cp_r).with("#{AppConf.application_dir}/template/.", 'dir')
        FileUtils.expects(:mkdir_p).with(File.join('dir', 'packages'))
        generate ['dir']
      end

      it 'generation is aborted at user request' do
        expects(:ask).with('Folder already exists. Overwrite (y/n)? ').returns 'n'
        generate ['dir']
      end
    end
  end

  describe 'htpasswd' do
    it 'htpasswd is generated and saved' do
      AppConf.webserver = 'server'
      $input.answers = %w(user pass pass)
      htpasswd nil
      File.read('server/conf/htpasswd').must_match /user:.{13}/
    end
  end

  describe 'init' do
    it 'initializes some AppConf settings and loads configs' do
      Machines::Command.file = nil
      Machines::Command.console = nil
      Machines::Command.debug = nil
      init
      AppConf.passwords.must_equal []
      AppConf.commands.must_equal []
      AppConf.webapps.must_equal {}
      AppConf.tasks.must_equal {}
      AppConf.timezone.must_equal 'GB'
      File.exist?('log/output.log').must_equal true
      Machines::Command.file.must_be_kind_of Machines::Logger
      Machines::Command.console.must_be_kind_of Machines::Logger
      Machines::Command.debug.must_be_kind_of Machines::Logger
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
    before do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
    end

    it 'copies package to project folder' do
      override 'base'
      File.exist?('packages/base.rb').must_equal true
    end

    describe 'when copying over existing package' do
      before do
        FileUtils.touch 'packages/base.rb'
      end

      it 'terminates when user answer no' do
        $input.answers = %w(n)
        override 'base'
        $output.must_equal 'Project package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.answers = %w(y)
        override 'base'
        $output.must_equal 'Project package already exists. Overwrite? (y/n)
Package copied to packages/base.rb
'
      end
    end
  end

  describe 'packages' do
    it 'displays a list of default and project packages' do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
      FileUtils.touch File.join('packages', 'apps.rb')
      packages
      $output.must_equal 'Default packages
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
      AppConf.tasks = {
        :task1 => {:description => 'description 1'},
        :task2 =>  {:description => 'description 2'},
        :task3 => {:description => 'description 3'}
      }
      tasks
      $output.must_equal 'Tasks
  task1                description 1
  task2                description 2
  task3                description 3
'
    end
  end
end
=end


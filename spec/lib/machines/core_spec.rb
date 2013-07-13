require 'spec_helper'

describe Core do

  subject { Core.new }

  before do
    @command1 = Machines::Command.new('command 1', 'check 1')
    @command2 = Machines::Command.new('command 2', 'check 2')
  end

  describe 'generate_password' do
    it 'generates a random password' do
      WEBrick::Utils.stubs(:random_string).with(20).returns '01234567890123456789'
      subject.generate_password.must_equal '01234567890123456789'
    end
  end

  describe 'package' do
    it 'raises specific error when failing to load Machinesfile' do
      File.expects(:read).never
      lambda{ subject.package 'Machinesfile' }.must_raise LoadError, /Cannot find Machinesfile/
    end

    it 'loads custom package when it exists' do
      custom_package = "packages/custom_package.rb"
      FileUtils.mkdir_p File.dirname(custom_package)
      FileUtils.touch custom_package
      subject.package :custom_package
    end

    it 'loads built-in package when no custom package' do
      builtin_package = "#{$conf.application_dir}/packages/builtin_package.rb"
      FileUtils.mkdir_p File.dirname(builtin_package)
      FileUtils.touch builtin_package
      subject.package :builtin_package
    end

    it 'raises when no custom and no built-in package' do
      File.expects(:read).never
      lambda { subject.package :builtin_package}.must_raise LoadError, /Cannot find .* package builtin_package/
    end
  end

  describe 'task' do
    it 'yields' do
      yielded = false
      subject.task :name do
        yielded = true
      end
      yielded.must_equal true
    end

    it 'logs the task' do
      subject.task :name, 'description' do
      end
      $conf.commands.first.info.must_equal "TASK   name - description"
    end

    it 'stores task' do
      block = Proc.new {}
      subject.task :name, 'description', &block
      $conf.tasks.must_equal :name => {:description => 'description', :block => block}
    end

    it 'sets commands to only run those from the specified tasks' do
      block_run_count = 0
      block = Proc.new { block_run_count += 1 }
      $conf.tasks[:task1] = {:block => block}
      $conf.tasks[:task2] = {:block => block}
      subject.task [:task1, 'task2']
      block_run_count.must_equal 2
    end

    it 'sets commands to only run those of a single task' do
      block_run = false
      block = Proc.new { block_run = true }
      $conf.tasks[:task] = {:block => block}
      subject.task :task
      block_run.must_equal true
    end

    describe 'when dependent task' do
      before(:each) do
        @yielded = false
        @block = Proc.new { @yielded = true }
      end

      describe 'exists' do
        before(:each) do
          subject.store_task :dependent_task, nil
          subject.task :name, nil, :if => :dependent_task, &@block
        end

        it { @yielded.must_equal true }
        it 'task stored' do
          $conf.tasks.must_include :name
        end
      end

      describe 'does not exist' do
        before(:each) { subject.task :name, nil, :if => :dependent_task, &@block }
        it { @yielded.must_equal false }
        it 'task not stored' do
          $conf.tasks.wont_include :name
        end
      end
    end

    describe 'when multiple dependent tasks' do
      before(:each) do
        @yielded = false
        @block = Proc.new { @yielded = true }
      end

      describe 'all exist' do
        before(:each) do
          subject.store_task :dependent_task, nil
          subject.store_task :another_dependent, nil
          subject.task :name, nil, :if => [:dependent_task, :another_dependent], &@block
        end

        it { @yielded.must_equal true }
        it 'task stored' do
          $conf.tasks.must_include :name
        end
      end

      describe 'all but one exist' do
        before(:each) do
          subject.store_task :another_dependent, nil
          subject.task :name, nil, :if => [:dependent_task, :another_dependent], &@block
        end

        it { @yielded.must_equal false }
        it 'task not stored' do
          $conf.tasks.wont_include :name
        end
      end
    end
  end

  describe 'only' do
    it 'yields when matched' do
      subject.expects(:matched).with('options').returns true
      yielded = false
      subject.only 'options' do
        yielded = true
      end
      yielded.must_equal true
    end

    it 'does not yield when not matched' do
      subject.expects(:matched).with('options').returns false
      yielded = false
      subject.only 'options' do
        yielded = true
      end
      yielded.must_equal false
    end

    it 'yields when symbol matches string' do
      $conf.environment = 'development'
      yielded = false
      subject.only :environment => :development do
        yielded = true
      end
      yielded.must_equal true
    end
  end

  describe 'except' do
    it 'does not yield when matched' do
      subject.expects(:matched).with('options').returns true
      yielded = false
      subject.except 'options' do
        yielded = true
      end
      yielded.must_equal false
    end

    it 'yields when not matched' do
      subject.expects(:matched).with('options').returns false
      yielded = false
      subject.except 'options' do
        yielded = true
      end
      yielded.must_equal true
    end
  end

  describe 'matched' do
    describe '$conf values are strings' do
      before do
        $conf.string_param = 'matched'
      end

      it { subject.matched(:string_param => :matched).must_equal true }
      it { subject.matched(:string_param => 'matched').must_equal true }
      it { subject.matched(:string_param => :unmatched).wont_equal true }
    end

    describe '$conf values are arrays' do
      before do
        $conf.params_array = [:matched, :another]
      end

      describe 'options values are arrays of symbols' do
        it { subject.matched({:params_array => [:matched]}).must_equal true }
        it { subject.matched({:params_array => [:unmatched]}).wont_equal true }
      end

      describe 'options values are arrays of strings' do
        it { subject.matched({'params_array' => ['matched']}).must_equal true }
        it { subject.matched({'params_array' => ['unmatched']}).wont_equal true }
      end

      describe 'options values are symbols' do
        it { subject.matched({:params_array => :matched}).must_equal true }
        it { subject.matched({:params_array => :unmatched}).wont_equal true }
      end

      describe 'options values are strings' do
        it { subject.matched({:params_array => 'matched'}).must_equal true }
        it { subject.matched({:params_array => 'unmatched'}).wont_equal true }
      end
    end

    describe '$conf values are symbols' do
      before do
        $conf.single_param = :matched
      end

      describe 'options values are arrays' do
        it { subject.matched({:single_param => [:matched]}).must_equal true }
        it { subject.matched({:single_param => [:unmatched]}).wont_equal true }
      end

      describe 'options values are symbols' do
        it { subject.matched({:single_param => :matched}).must_equal true }
        it { subject.matched({:single_param => :unmatched}).wont_equal true }
      end
    end
  end

  describe 'run' do
    it 'adds a command to the commands array' do
      subject.run @command1
      $conf.commands.must_equal [@command1]
    end

    it 'appends several commands' do
      subject.run @command1
      subject.run @command2
      $conf.commands.must_equal [@command1, @command2]
    end

    it 'appends several commands in a single call' do
      subject.run @command1, @command2
      $conf.commands.must_equal [@command1, @command2]
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        subject.run 'command', 'check'
        $conf.commands.first.command.must_equal 'command'
        $conf.commands.first.check.must_equal 'check'
      end
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      $conf.password = 'password'
      @command1.expects(:use_sudo)
      subject.sudo @command1
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        subject.sudo 'command', 'check'
        $conf.commands.first.command.must_equal 'command'
        $conf.commands.first.check.must_equal 'check'
      end
    end

    describe 'upload' do
      it 'modifies Upload to send it to a temp file and sudos to copy it to destination' do
        File.stubs(:directory?).returns false
        subject.sudo subject.upload 'source', 'dest'

        $conf.commands.map(&:command).must_equal [nil, "cp -rf /tmp/dest dest", "rm -rf /tmp/dest"]
        $conf.commands.map(&:check).must_equal [
          "test -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED",
          "test -s dest && echo CHECK PASSED || echo CHECK FAILED",
          "test ! -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED"
        ]
      end

      it 'adds /. to the end of folder paths' do
        File.stubs(:directory?).with('source').returns true
        subject.sudo subject.upload 'source', 'dest'
        $conf.commands.map(&:command).must_equal [nil, "cp -rf /tmp/dest/. dest", "rm -rf /tmp/dest"]
      end
    end
  end

  describe 'required_options' do
    it 'does not raise when option exists' do
      subject.required_options({:required => :option}, [:required])
    end

    it 'raises when option does not exist' do
      lambda{ subject.required_options({}, [:required]) }.must_raise(ArgumentError)
    end
  end
end


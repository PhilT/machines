require 'spec_helper'

describe 'Core' do
  include Machines::Core
  include Machines::FileOperations

  before(:each) do
    alias :run :run_command # alias Machines::Core.run back so it can be called by sudo and the tests etc
    @command1 = Machines::Command.new('command 1', 'check 1')
    @command2 = Machines::Command.new('command 2', 'check 2')
  end

  describe 'generate_password' do
    it 'generates a random password' do
      WEBrick::Utils.stubs(:random_string).with(20).returns '01234567890123456789'
      generate_password.must_equal '01234567890123456789'
    end
  end

  describe 'task' do
    it 'yields' do
      yielded = false
      task :name do
        yielded = true
      end
      yielded.must_equal true
    end

    it 'logs the task' do
      task :name, 'description' do
      end
      AppConf.commands.first.info.must_equal "TASK   name - description"
    end

    it 'stores task' do
      block = Proc.new {}
      task :name, 'description', &block
      AppConf.tasks.must_equal :name => {:description => 'description', :block => block}
    end

    it 'sets commands to only run those from the specified task' do
      block_ran = false
      block = Proc.new { block_ran = true }
      AppConf.tasks[:name] = {:block => block}
      task :name, nil
      block_ran.must_equal true
    end

    describe 'when dependent task' do
      before(:each) do
        @yielded = false
        @block = Proc.new { @yielded = true }
      end

      describe 'exists' do
        before(:each) do
          store_task :dependent_task, nil
          task :name, nil, :if => :dependent_task, &@block
        end

        it { @yielded.must_equal true }
        it 'task stored' do
          AppConf.tasks.must_include :name
        end
      end

      describe 'does not exist' do
        before(:each) { task :name, nil, :if => :dependent_task, &@block }
        it { @yielded.must_equal false }
        it 'task not stored' do
          AppConf.tasks.wont_include :name
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
          store_task :dependent_task, nil
          store_task :another_dependent, nil
          task :name, nil, :if => [:dependent_task, :another_dependent], &@block
        end

        it { @yielded.must_equal true }
        it 'task stored' do
          AppConf.tasks.must_include :name
        end
      end

      describe 'all but one exist' do
        before(:each) do
          store_task :another_dependent, nil
          task :name, nil, :if => [:dependent_task, :another_dependent], &@block
        end

        it { @yielded.must_equal false }
        it 'task not stored' do
          AppConf.tasks.wont_include :name
        end
      end
    end
  end

  describe 'list_tasks' do
    it 'displays a list of tasks' do
      task :name, 'description', &Proc.new {}
      task :another, 'another description', &Proc.new {}
      list_tasks
      $output.buffer.must_equal '  name                description
  another             another description
'
    end
  end

  describe 'only' do
    it 'yields when matched' do
      expects(:matched).with('options').returns true
      yielded = false
      only 'options' do
        yielded = true
      end
      yielded.must_equal true
    end

    it 'does not yield when not matched' do
      expects(:matched).with('options').returns false
      yielded = false
      only 'options' do
        yielded = true
      end
      yielded.must_equal false
    end
  end

  describe 'except' do
    it 'does not yield when matched' do
      expects(:matched).with('options').returns true
      yielded = false
      except 'options' do
        yielded = true
      end
      yielded.must_equal false
    end

    it 'yields when not matched' do
      expects(:matched).with('options').returns false
      yielded = false
      except 'options' do
        yielded = true
      end
      yielded.must_equal true
    end
  end

  describe 'matched' do
    describe 'AppConf values are arrays' do
      before do
        AppConf.params_array = [:matched, :another]
      end

      describe 'options values are arrays of symbols' do
        it { matched({:params_array => [:matched]}).must_equal true }
        it { matched({:params_array => [:unmatched]}).wont_equal true }
      end

      describe 'options values are arrays of strings' do
        it { matched({'params_array' => ['matched']}).must_equal true }
        it { matched({'params_array' => ['unmatched']}).wont_equal true }
      end

      describe 'options values are symbols' do
        it { matched({:params_array => :matched}).must_equal true }
        it { matched({:params_array => :unmatched}).wont_equal true }
      end

      describe 'options values are strings' do
        it { matched({:params_array => 'matched'}).must_equal true }
        it { matched({:params_array => 'unmatched'}).wont_equal true }
      end
    end

    describe 'AppConf values are symbols' do
      before do
        AppConf.single_param = :matched
      end

      describe 'options values are arrays' do
        it { matched({:single_param => [:matched]}).must_equal true }
        it { matched({:single_param => [:unmatched]}).wont_equal true }
      end

      describe 'options values are symbols' do
        it { matched({:single_param => :matched}).must_equal true }
        it { matched({:single_param => :unmatched}).wont_equal true }
      end
    end
  end

  describe 'run' do
    it 'adds a command to the commands array' do
      run @command1
      AppConf.commands.must_equal [@command1]
    end

    it 'appends several commands' do
      run @command1
      run @command2
      AppConf.commands.must_equal [@command1, @command2]
    end

    it 'appends several commands in a single call' do
      run @command1, @command2
      AppConf.commands.must_equal [@command1, @command2]
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        run 'command', 'check'
        AppConf.commands.first.command.must_equal 'command'
        AppConf.commands.first.check.must_equal 'check'
      end
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.password = 'password'
      @command1.expects(:use_sudo)
      sudo @command1
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        sudo 'command', 'check'
        AppConf.commands.first.command.must_equal 'command'
        AppConf.commands.first.check.must_equal 'check'
      end
    end
  end

  describe 'upload' do
    subject { upload 'source', 'dest' }
    it { subject.local.must_equal 'source' }
    it { subject.remote.must_equal 'dest' }
  end

  describe 'sudo upload' do
    it 'modifies Upload to send it to a temp file and sudos to copy it to destination' do
      File.stubs(:directory?).returns false
      sudo upload 'source', 'dest'

      AppConf.commands.map(&:command).must_equal [nil, "cp -rf /tmp/dest dest", "rm -rf /tmp/dest"]
      AppConf.commands.map(&:check).must_equal [
        "test -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED",
        "test -s dest && echo CHECK PASSED || echo CHECK FAILED",
        "test ! -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED"
      ]
    end

    it 'adds /. to the end of folder paths' do
      File.stubs(:directory?).with('source').returns true
      sudo upload 'source', 'dest'
      AppConf.commands.map(&:command).must_equal [nil, "cp -rf /tmp/dest/. dest", "rm -rf /tmp/dest"]
    end
  end

  describe 'required_options' do
    it 'does not raise when option exists' do
      required_options({:required => :option}, [:required])
    end

    it 'raises when option does not exist' do
      lambda{required_options({}, [:required])}.must_raise(ArgumentError)
    end
  end
end


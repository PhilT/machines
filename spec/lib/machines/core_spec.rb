require 'spec_helper'

describe 'Configuration' do
  include Machines::Core
  include Machines::FileOperations

  before(:each) do
    @command1 = Command.new('command 1', 'check 1')
    @command2 = Command.new('command 2', 'check 2')
  end

  describe 'generate_password' do
    it 'generates a random password' do
      WEBrick::Utils.stub(:random_string).with(20).and_return '01234567890123456789'
      generate_password.should == '01234567890123456789'
    end
  end

  describe 'task' do
    it 'yields' do
      yielded = false
      task :name do
        yielded = true
      end
      yielded.should be_true
    end

    it 'logs the task' do
      task :name, 'description' do
      end
      AppConf.commands.first.info.should == "TASK   name - description"
    end

    it 'stores task' do
      block = Proc.new {}
      task :name, 'description', &block
      AppConf.tasks.should == {:name => {:description => 'description', :block => block}}
    end

    it 'sets commands to only run those from the specified task' do
      block_ran = false
      block = Proc.new { block_ran = true }
      AppConf.tasks[:name] = {:block => block}
      task :name, nil
      block_ran.should be_true
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

        it { @yielded.should be_true }
        it 'task stored' do
          AppConf.tasks.should include :name
        end
      end

      describe 'does not exist' do
        before(:each) { task :name, nil, :if => :dependent_task, &@block }
        it { @yielded.should be_false }
        it 'task not stored' do
          AppConf.tasks.should_not include :name
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

        it { @yielded.should be_true }
        it 'task stored' do
          AppConf.tasks.should include :name
        end
      end

      describe 'all but one exist' do
        before(:each) do
          store_task :another_dependent, nil
          task :name, nil, :if => [:dependent_task, :another_dependent], &@block
        end

        it { @yielded.should be_false }
        it 'task not stored' do
          AppConf.tasks.should_not include :name
        end
      end
    end
  end

  describe 'list_tasks' do
    it 'displays a list of tasks' do
      task :name, 'description', &Proc.new {}
      task :another, 'another description', &Proc.new {}
      list_tasks
      $output.should == '  name                description
  another             another description
'
    end
  end

  describe 'only' do
    it 'yields when matched' do
      should_receive(:matched).with('options').and_return true
      yielded = false
      only 'options' do
        yielded = true
      end
      yielded.should be_true
    end

    it 'does not yield when not matched' do
      should_receive(:matched).with('options').and_return false
      yielded = false
      only 'options' do
        yielded = true
      end
      yielded.should be_false
    end
  end

  describe 'except' do
    it 'does not yield when matched' do
      should_receive(:matched).with('options').and_return true
      yielded = false
      except 'options' do
        yielded = true
      end
      yielded.should be_false
    end

    it 'yields when not matched' do
      should_receive(:matched).with('options').and_return false
      yielded = false
      except 'options' do
        yielded = true
      end
      yielded.should be_true
    end
  end

  describe 'matched' do
    describe 'AppConf values are arrays' do
      before do
        AppConf.params_array = [:matched, :another]
      end

      describe 'options values are arrays of symbols' do
        it { matched({:params_array => [:matched]}).should be_true }
        it { matched({:params_array => [:unmatched]}).should be_false }
      end

      describe 'options values are arrays of strings' do
        it { matched({'params_array' => ['matched']}).should be_true }
        it { matched({'params_array' => ['unmatched']}).should be_false }
      end

      describe 'options values are symbols' do
        it { matched({:params_array => :matched}).should be_true }
        it { matched({:params_array => :unmatched}).should be_false }
      end

      describe 'options values are strings' do
        it { matched({:params_array => 'matched'}).should be_true }
        it { matched({:params_array => 'unmatched'}).should be_false }
      end
    end

    describe 'AppConf values are symbols' do
      before do
        AppConf.single_param = :matched
      end

      describe 'options values are arrays' do
        it { matched({:single_param => [:matched]}).should be_true }
        it { matched({:single_param => [:unmatched]}).should be_false }
      end

      describe 'options values are symbols' do
        it { matched({:single_param => :matched}).should be_true }
        it { matched({:single_param => :unmatched}).should be_false }
      end
    end
  end

  describe 'run' do
    it 'adds a command to the commands array' do
      run @command1
      AppConf.commands.should == [@command1]
    end

    it 'appends several commands' do
      run @command1
      run @command2
      AppConf.commands.should == [@command1, @command2]
    end

    it 'appends several commands in a single call' do
      run @command1, @command2
      AppConf.commands.should == [@command1, @command2]
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        run 'command', 'check'
        AppConf.commands.first.command.should == 'command'
        AppConf.commands.first.check.should == 'check'
      end
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.password = 'password'
      @command1.should_receive(:use_sudo)
      sudo @command1
    end

    describe 'when commands are two strings' do
      it 'creates a Command' do
        sudo 'command', 'check'
        AppConf.commands.first.command.should == 'command'
        AppConf.commands.first.check.should == 'check'
      end
    end
  end

  describe 'upload' do
    subject { upload 'source', 'dest' }
    it { subject.local.should == 'source' }
    it { subject.remote.should == 'dest' }
  end

  describe 'sudo upload' do
    it 'modifies Upload to send it to a temp file and sudos to copy it to destination' do
      File.stub(:directory?).and_return false
      sudo upload 'source', 'dest'

      AppConf.commands.map(&:command).should == [nil, "cp -rf /tmp/dest dest", "rm -rf /tmp/dest"]
      AppConf.commands.map(&:check).should == [
        "test -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED",
        "test -s dest && echo CHECK PASSED || echo CHECK FAILED",
        "test ! -s /tmp/dest && echo CHECK PASSED || echo CHECK FAILED"
      ]
    end

    it 'adds /. to the end of folder paths' do
      File.stub(:directory?).with('source').and_return true
      sudo upload 'source', 'dest'
      AppConf.commands.map(&:command).should == [nil, "cp -rf /tmp/dest/. dest", "rm -rf /tmp/dest"]
    end
  end

  describe 'required_options' do
    it do
      lambda{required_options({:required => :option}, [:required])}.should_not raise_error(ArgumentError)
    end

    it do
      lambda{required_options({}, [:required])}.should raise_error(ArgumentError)
    end
  end
end


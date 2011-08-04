require 'spec_helper'

describe 'Configuration' do
  include Machines::Core
  include Machines::FileOperations

  before(:each) do
    @command1 = Command.new('command 1', 'check 1')
    @command2 = Command.new('command 2', 'check 2')
  end

  describe 'task' do
    it 'yields' do
      yielded = false
      task 'description' do
        yielded = true
      end
      yielded.should be_true
    end

    it 'stores task' do
      block = Proc.new {}
      task :name, 'description', &block
      AppConf.tasks.should == {:name => {:description => 'description', :block => block}}
    end

    it 'sets commands to only those of the specified task' do
      block_ran = false
      block = Proc.new { block_ran = true }
      AppConf.tasks[:name] = {:block => block}
      task :name
      block_ran.should be_true
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
    context 'AppConf values are arrays' do
      before do
        AppConf.params_array = [:matched, :another]
      end

      context 'options values are arrays' do
        it { matched({:params_array => [:matched]}).should be_true }
        it { matched({:params_array => [:unmatched]}).should be_false }
      end

      context 'options values are symbols' do
        it { matched({:params_array => :matched}).should be_true }
        it { matched({:params_array => :unmatched}).should be_false }
      end
    end

    context 'AppConf values are symbols' do
      before do
        AppConf.single_param = :matched
      end

      context 'options values are arrays' do
        it { matched({:single_param => [:matched]}).should be_true }
        it { matched({:single_param => [:unmatched]}).should be_false }
      end

      context 'options values are symbols' do
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

    context 'when commands are two strings' do
      it 'creates a Command' do
        run 'command', 'check'
        AppConf.commands.should == [Command.new('command', 'check')]
      end
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.user.pass = 'password'
      @command1.should_receive(:use_sudo)
      sudo @command1
    end

    context 'when commands are two strings' do
      it 'creates a Command' do
        sudo 'command', 'check'
        AppConf.commands.should == [Command.new('command', 'check')]
      end
    end
  end

  describe 'upload' do
    subject { upload 'source', 'dest' }
    it { subject.local.should == 'source' }
    it { subject.remote.should == 'dest' }
  end

  describe 'sudo upload' do
    before { Time.stub(:now).and_return Time.new(2011, 4, 2, 16, 37) }

    it 'modifies Upload to send it to a temp file and sudos to copy it to destination' do
      sudo upload 'source', 'dest'

      copy_command = Command.new("cp upload1301758620 dest", check_file('dest'))
      copy_command.use_sudo
      AppConf.commands.should == [
        Upload.new('source', 'upload1301758620', check_file('upload1301758620')),
        copy_command,
        Command.new("rm -f upload1301758620", check_file('upload1301758620', false))
      ]
    end
  end
end


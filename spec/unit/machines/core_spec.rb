require 'spec_helper'

describe 'Configuration' do
  include Machines::Core
  include Machines::FileOperations
  include FakeFS::SpecHelpers

  before(:each) do
    @command1 = Command.new('command 1', 'check 1')
    @command2 = Command.new('command 2', 'check 2')
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
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.user.pass = 'password'
      @command1.should_receive(:use_sudo)
      sudo @command1
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


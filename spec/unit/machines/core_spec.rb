require 'spec_helper'

describe 'Configuration' do
  include Machines::Core
  include Machines::FileOperations

  describe 'run' do
    before(:each) do
      AppConf.commands = []
    end

    it 'adds a command to the commands array and include the caller method name' do
      stub!(:caller).and_return ["(eval):13\nrest of trace"]
      run 'command', nil
      AppConf.commands.should == [Command.new('13', 'export TERM=linux && command', nil)]
    end

    it 'does not fail when no trace' do
      stub!(:caller).and_return []
      run 'command', nil
      AppConf.commands.should == [Command.new('', 'export TERM=linux && command', nil)]
    end

    it 'concatenates multiple commands in one call' do
      run ['command 1', 'command 2'], nil
      AppConf.commands.first.command.should == 'export TERM=linux && command 1 && command 2'
    end

    it 'appends several commands' do
      run 'command 1', nil
      run 'command 2', nil
      AppConf.commands.map(&:command).should == ['export TERM=linux && command 1', 'export TERM=linux && command 2']
    end

    it 'adds the check' do
      run 'command 1', 'check'
      AppConf.commands.first.should == Command.new('', 'export TERM=linux && command 1', 'check')
    end

    it 'raises errors when command is missing' do
      stub!(:display)
      lambda{run [nil, nil]}.should raise_error(ArgumentError)
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.user.pass = 'password'
      sudo 'command', nil
      AppConf.commands.should == [Command.new('', "echo password | sudo -S sh -c 'export TERM=linux && command'", nil)]
    end
  end

  describe 'upload' do
    it 'adds an upload command' do
      File.should_receive(:directory?).with('source').and_return(false)
      Dir.should_not_receive(:[])
      upload 'source', 'dest'
      AppConf.commands.map(&:local_source).should == ['source']
      AppConf.commands.map(&:remote_dest).should == ['dest']
    end

    it 'creates remote directories to match local' do
      File.should_receive(:directory?).with('source').and_return(true)
      Dir.should_receive(:[]).with('source/**/*').and_return(%w(source/dir))
      File.should_receive(:directory?).with('source/dir').and_return(true)
      upload 'source', 'dest'
      AppConf.commands.map(&:command).should == ['export TERM=linux && mkdir -p dest/dir']
    end

    it 'adds multiple upload commands for a directory' do
      File.should_receive(:directory?).with('source/dir/').and_return(true)
      Dir.should_receive(:[]).with('source/dir/**/*').and_return(%w(source/dir/file1 source/dir/subdir/file2))
      File.should_receive(:directory?).with('source/dir/file1').and_return(false)
      File.should_receive(:directory?).with('source/dir/subdir/file2').and_return(false)
      upload 'source/dir/', 'dest'
      AppConf.commands.map(&:local_source).should == ['source/dir/file1', 'source/dir/subdir/file2']
      AppConf.commands.map(&:remote_dest).should == ['dest/file1', 'dest/subdir/file2']
    end

    it 'works with a real example' do
      structure = [
        ['users/phil/gconf/apps', true],
        ['users/phil/gconf/apps/metacity', true],
        ['users/phil/gconf/apps/metacity/general', true],
        ['users/phil/gconf/apps/metacity/general/%gconf.xml', false]
      ]

      File.should_receive(:directory?).with('users/phil/gconf').and_return(true)
      Dir.should_receive(:[]).with('users/phil/gconf/**/*').and_return(structure.map{|path, dir| path})
      structure.each {|path, dir|File.should_receive(:directory?).with(path).and_return dir}
      upload 'users/phil/gconf', '~/.gconf'
      AppConf.commands.should == [
        Command.new('', 'export TERM=linux && mkdir -p ~/.gconf/apps', 'test -d ~/.gconf/apps && echo CHECK PASSED || echo CHECK FAILED'),
        Command.new('', 'export TERM=linux && mkdir -p ~/.gconf/apps/metacity', 'test -d ~/.gconf/apps/metacity && echo CHECK PASSED || echo CHECK FAILED'),
        Command.new('', 'export TERM=linux && mkdir -p ~/.gconf/apps/metacity/general', 'test -d ~/.gconf/apps/metacity/general && echo CHECK PASSED || echo CHECK FAILED'),
        Upload.new('', 'users/phil/gconf/apps/metacity/general/%gconf.xml', '~/.gconf/apps/metacity/general/%gconf.xml', 'test -s ~/.gconf/apps/metacity/general/%gconf.xml && echo CHECK PASSED || echo CHECK FAILED')
      ]
    end
  end
end


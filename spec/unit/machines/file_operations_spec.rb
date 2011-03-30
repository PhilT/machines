require 'spec_helper'

describe 'FileOperations' do
  include Machines::Core
  include Machines::FileOperations

  describe 'rename' do
    it 'renames a remote file' do
      rename 'oldname', 'newname'
      AppConf.commands.map(&:command).should == ['export TERM=linux && mv oldname newname']
      AppConf.commands.map(&:check).should == ["test -s newname #{echo_result}"]
    end
  end

  describe 'copy' do
    it 'copies a remote file' do
      copy 'this', 'that'
      AppConf.commands.map(&:command).should == ['export TERM=linux && cp this that']
      AppConf.commands.map(&:check).should == ["test -s that #{echo_result}"]
    end
  end

  describe 'remove' do
    it 'removes a file' do
      remove 'file'
      AppConf.commands.map(&:command).should == ['export TERM=linux && rm file']
      AppConf.commands.map(&:check).should == ["test ! -s file #{echo_result}"]
    end

    it 'forcefully removes a file' do
      remove 'file', :force => true
      AppConf.commands.map(&:command).should == ['export TERM=linux && rm -f file']
    end
  end

  describe 'remove_version_info' do
    it 'adds command to remove version info' do
      remove_version_info 'name'
      AppConf.commands.map(&:command).should == ["export TERM=linux && find . -maxdepth 1 -name 'name*' -a -type d | xargs -I xxx mv xxx name"]
    end
  end

  describe 'link' do
    it 'adds a command to symlink a path' do
      link 'target', 'link'
      AppConf.commands.map(&:command).should == ['export TERM=linux && ln -sf target link']
    end
  end

  describe 'replace' do
    it 'replaces some text in a file' do
      should_receive(:required_options).with({:with => 'else', :in => 'file'}, [:with, :in])
      replace 'something', {:with => 'else', :in => 'file'}
      AppConf.commands.map(&:command).should == ["export TERM=linux && sed -i 's/something/else/' file"]
    end

    it 'replaces text with / in a file' do
      stub!(:required_options)
      replace 'something', {:with => 'some/path', :in => 'file'}
      AppConf.commands.map(&:command).should == ["export TERM=linux && sed -i 's/something/some\\/path/' file"]
    end

    it 'replaces symbols' do
      stub!(:required_options)
      replace 'something', {:with => :else, :in => 'file'}
      AppConf.commands.map(&:command).should == ["export TERM=linux && sed -i 's/something/else/' file"]
    end
  end

  describe 'mkdir' do
    it 'creates a path' do
      mkdir 'path'
      AppConf.commands.map(&:command).should == ['export TERM=linux && mkdir -p path']
    end

    it 'should create a path and set permissions' do
      mkdir 'path', 600
      AppConf.commands.map(&:command).should == ['export TERM=linux && mkdir -p path', 'export TERM=linux && chmod 600 path']
     end
   end

  describe 'chmod' do
    it 'adds a command to change permissions of a file or folder' do
      chmod 'mode', 'path'
      AppConf.commands.map(&:command).should == ['export TERM=linux && chmod mode path']
    end

    it 'handles integer modes' do
      chmod 644, 'path'
      AppConf.commands.first.command.should == 'export TERM=linux && chmod 644 path'
    end

    it 'handles string modes' do
      chmod '644', 'path'
      AppConf.commands.first.command.should == 'export TERM=linux && chmod 644 path'
    end
  end

  describe 'chown' do
    it 'adds a command to change ownership of a file or folder' do
      chown 'owner', 'path'
      AppConf.commands.map(&:command).should == ['export TERM=linux && chown owner:owner path']
    end
  end
end


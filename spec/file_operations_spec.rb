require 'spec_helper'

describe 'FileOperations' do
  include Machines::FileOperations
  include FakeAddHelper

  describe 'upload' do
    it 'should add an upload command' do
      File.should_receive(:directory?).with('source').and_return(false)
      Dir.should_not_receive(:[])
      upload 'source', 'dest'
      @added.should == [['source', 'dest']]
      @checks.should == ["test -s dest #{pass_fail}"]
    end

    it 'should add an upload command with permissions and owner' do
      File.should_receive(:directory?).with('source').and_return(false)
      Dir.should_not_receive(:[])
      upload 'source', 'dest', {:perms => '123', :owner => 'owner'}
      @added.should == [['source', 'dest'], 'chmod 123 dest', 'chown owner:owner dest']
    end

    it 'should create remote directories to match local' do
      File.should_receive(:directory?).with('source').and_return(true)
      Dir.should_receive(:[]).with('source/**/*').and_return(%w(source/dir))
      File.should_receive(:directory?).with('source/dir').and_return(true)
      upload 'source', 'dest'
      @added.should == ['mkdir -p dest/dir']
    end

    it 'should add multiple upload commands for a directory' do
      File.should_receive(:directory?).with('source/dir/').and_return(true)
      Dir.should_receive(:[]).with('source/dir/**/*').and_return(%w(source/dir/file1 source/dir/subdir/file2))
      File.should_receive(:directory?).with('source/dir/file1').and_return(false)
      File.should_receive(:directory?).with('source/dir/subdir/file2').and_return(false)
      upload 'source/dir/', 'dest', :owner => 'owner'
      @added.should == [
        ['source/dir/file1', 'dest/file1'],
        ['source/dir/subdir/file2', 'dest/subdir/file2'],
        'chown -R owner:owner dest'
      ]
    end

    it 'should work with a real example' do
      structure = [
        ['users/phil/gconf/apps', true],
        ['users/phil/gconf/apps/metacity', true],
        ['users/phil/gconf/apps/metacity/general', true],
        ['users/phil/gconf/apps/metacity/general/%gconf.xml', false]
      ]

      File.should_receive(:directory?).with('users/phil/gconf').and_return(true)
      Dir.should_receive(:[]).with('users/phil/gconf/**/*').and_return(structure.map{|path, dir| path})
      structure.each {|path, dir|File.should_receive(:directory?).with(path).and_return dir}
      upload 'users/phil/gconf', '~/.gconf', :owner => 'owner'
      @added.should == [
        'mkdir -p ~/.gconf/apps',
        'mkdir -p ~/.gconf/apps/metacity',
        'mkdir -p ~/.gconf/apps/metacity/general',
        ['users/phil/gconf/apps/metacity/general/%gconf.xml', '~/.gconf/apps/metacity/general/%gconf.xml'],
        'chown -R owner:owner ~/.gconf'
      ]
    end
  end

  describe 'rename' do
    it 'should rename a remote file' do
      rename 'oldname', 'newname'
      @added.should == ['mv oldname newname']
      @checks.should == ["test -s newname #{pass_fail}"]
    end
  end

  describe 'copy' do
    it 'should copy a remote file' do
      copy 'this', 'that'
      @added.should == ['cp this that']
      @checks.should == ["test -s that #{pass_fail}"]
    end
  end

  describe 'remove' do
    it 'should remove a file' do
      remove 'file'
      @added.should == ['rm file']
      @checks.should == ["test -s file #{fail_pass}"]
    end

    it 'should forcefully remove a file' do
      remove 'file', :force => true
      @added.should == ['rm -f file']
    end
  end

  describe 'remove_version_info' do
    it 'should add command to remove version info' do
      remove_version_info 'name'
      @added.should == ["find . -maxdepth 1 -name 'name*' -a -type d | xargs -I xxx mv xxx name"]
    end
  end

  describe 'link' do
    it 'should add a command to symlink a path' do
      link 'from', :to => 'to'
      @added.should == ['ln -sf to from']
    end
  end

  describe 'replace' do
    it 'should replace some text in a file' do
      should_receive(:required_options).with({:with => 'else', :in => 'file'}, [:with, :in])
      replace 'something', {:with => 'else', :in => 'file'}
      @added.should == ["sed -i 's/something/else/' file"]
    end

    it 'should replace text with / in a file' do
      stub!(:required_options)
      replace 'something', {:with => 'some/path', :in => 'file'}
      @added.should == ["sed -i 's/something/some\\/path/' file"]
    end

    it 'should replace symbols' do
      stub!(:required_options)
      replace 'something', {:with => :else, :in => 'file'}
      @added.should == ["sed -i 's/something/else/' file"]
    end
  end

  describe 'mkdir' do
    it 'should create a path' do
      mkdir 'path'
      @added.should == ['mkdir -p path']
    end

    it 'should create a path with permissions and owner' do
      mkdir 'path', {:perms => '123', :owner => 'owner'}
      @added.should == ['mkdir -p path', 'chmod 123 path', 'chown owner:owner path']
    end
  end

  describe 'chmod' do
    it 'should add a command to change permissions of a file or folder' do
      chmod 'mod', 'path'
      @added.should == ['chmod mod path']
    end
  end

  describe 'chown' do
    it 'should add a command to change ownership of a file or folder' do
      chown 'owner', 'path'
      @added.should == ['chown owner:owner path']
    end
  end

  describe 'make_app_structure' do
    it 'should add commands to create the app folder structure' do
      make_app_structure 'path'
      @added.should == [
        'mkdir -p path/releases', 'chown ubuntu:ubuntu path/releases',
        'mkdir -p path/shared/config', 'chown ubuntu:ubuntu path/shared/config',
        'mkdir -p path/shared/system', 'chown ubuntu:ubuntu path/shared/system'
      ]
    end
  end
end


require 'spec_helper'

describe 'FileOperations' do
  describe 'append' do
    it 'escapes backslashes (\\)' do
      subject = append '\\', :to => 'file'
      subject.command.should =~ /"\\\\"/
    end

    it 'escapes dollar sign ($)' do
      subject = append '$', :to => 'file'
      subject.command.should =~ /"\\\$\"/
    end

    it 'escapes double quotes (")' do
      subject = append '"', :to => 'file'
      subject.command.should =~ /"\\""/
    end

    it 'escapes backticks (`)' do
      subject = append '`', :to => 'file'
      subject.command.should =~ /"\\`"/
    end

    it 'appends to a file' do
      subject = append 'string', :to => 'file'
      subject.command.should =~ /echo ".*" >> file/
    end

    it 'adds to a file with specified content including escaped characters' do
      subject = append '\\$"`', :to => 'file'
      subject.command.should == 'echo "\\\\\\$\\"\\`" >> file'
    end

    it 'checks text was added' do
      subject = append 'something', :to => 'file'
      subject.check.should == "grep \"something\" file #{echo_result}"
    end
  end

  describe 'chmod' do
    subject { chmod(644, 'path') }
    it { subject.command.should == 'chmod 644 path' }

    context 'when mode is a string' do
      subject { chmod('644', 'path') }
      it { subject.command.should == 'chmod 644 path' }
    end
  end

  describe 'chown' do
    subject { chown('owner', 'path') }
    it { subject.command.should == 'chown owner:owner path' }
  end

  describe 'copy' do
    subject { copy('from', 'to') }
    it { subject.command.should == 'cp -rf from to' }
  end

  describe 'create_from' do
    it 'loads ERB template, applies settings and writes to remote machine' do
      File.should_receive(:read).with('erb_path').and_return('<%= method_on_binding %>')
      should_receive(:write).with('result', hash_including(:to => 'file'))
      create_from('erb_path', :settings => AppBuilder.new(:method_on_binding => 'result'), :to => 'file')
    end
  end

  describe 'link' do
    subject { link 'target', 'link' }
    it {subject.command.should == 'ln -sf target link'}
  end

  describe 'mkdir' do
    subject { mkdir('path') }
    it { subject.command.should == 'mkdir -p path' }
   end

  describe 'rename' do
    subject { rename('oldname', 'newname') }
    it { subject.command.should == 'mv oldname newname' }
  end

  describe 'remove' do
    subject { remove 'file' }
    it { subject.command.should == 'rm -rf file' }
  end

  describe 'remove_version_info' do
    subject { remove_version_info 'name' }
    it { subject.command.should == "find . -maxdepth 1 -name \"name*\" -a -type d | xargs -I xxx mv xxx name" }
  end

  describe 'replace' do
    subject { replace('something', :with => 'some/path', :in => 'file') }
    it { subject.command.should == "sed -i \"s/something/some\\/path/\" file" }
    it { lambda{replace('something')}.should raise_error ArgumentError }
  end

  describe 'write' do
    it 'uploads from a buffer' do
      mock_named_buffer = mock NamedBuffer
      NamedBuffer.should_receive(:new).with('name', 'something').and_return mock_named_buffer
      subject = write('something', :to => 'a_file', :name => 'name')
      subject.local.should == mock_named_buffer
    end
  end
end


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
      subject.command.must_equal 'echo "\\\\\\$\\"\\`" >> file'
    end

    it 'checks text was added' do
      subject = append 'something', :to => 'file'
      subject.check.must_equal "grep \"something\" file #{echo_result}"
    end
  end

  describe 'chmod' do
    subject { chmod(644, 'path') }
    it { subject.command.must_equal 'chmod 644 path' }

    describe 'when mode is a string' do
      subject { chmod('644', 'path') }
      it { subject.command.must_equal 'chmod 644 path' }
    end
  end

  describe 'chown' do
    subject { chown('owner', 'path') }
    it { subject.command.must_equal 'chown owner:owner path' }
  end

  describe 'copy' do
    subject { copy('from', 'to') }
    it { subject.command.must_equal 'cp -rf from to' }
  end

  describe 'create_from' do
    it 'loads ERB template, applies settings and writes to remote machine' do
      File.expects(:read).with('erb_path').returns('<%= method_on_binding %>')
      expects(:write).with('result', hash_including(:to => 'file'))
      create_from('erb_path', :settings => AppBuilder.new(:method_on_binding => 'result'), :to => 'file')
    end
  end

  describe 'link' do
    subject { link 'target', 'link' }
    it {subject.command.must_equal 'ln -sf target link'}
  end

  describe 'mkdir' do
    subject { mkdir('path') }
    it { subject.command.must_equal 'mkdir -p path' }
   end

  describe 'rename' do
    subject { rename('oldname', 'newname') }
    it { subject.command.must_equal 'mv -f oldname newname' }
  end

  describe 'remove' do
    subject { remove 'file' }
    it { subject.command.must_equal 'rm -rf file' }
  end

  describe 'remove_version_info' do
    subject { remove_version_info 'name' }
    it { subject.command.must_equal "find . -maxdepth 1 -name \"name*\" -a -type d | xargs -I xxx mv xxx name" }
  end

  describe 'replace' do
    subject { replace('something', :with => 'some/path', :in => 'file') }
    it { subject.command.must_equal "sed -i \"s/something/some\\/path/\" file" }
    it { lambda{replace('something')}.must_raise ArgumentError }
  end

  describe 'write' do
    it 'uploads from a buffer' do
      mock_named_buffer = mock NamedBuffer
      NamedBuffer.expects(:new).with('name', 'something').returns mock_named_buffer
      subject = write('something', :to => 'a_file', :name => 'name')
      subject.local.must_equal mock_named_buffer
    end
  end
end


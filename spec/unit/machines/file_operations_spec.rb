require 'spec_helper'

describe 'FileOperations' do
  include Core
  include FileOperations
  include AppSettings

  describe 'rename' do
    subject { rename('oldname', 'newname') }
    it { subject.command.should == 'mv oldname newname' }
  end

  describe 'copy' do
    subject { copy('from', 'to') }
    it { subject.command.should == 'cp from to' }

    context 'when source is a directory' do
      before { FileUtils.mkdir_p 'from' }
      subject { copy('from', 'to') }
      it { subject.command.should == 'cp -R from to'}
    end
  end

  describe 'remove' do
    subject { remove 'file' }
    it { subject.command.should == 'rm -f file' }
  end

  describe 'remove_version_info' do
    subject { remove_version_info 'name' }
    it { subject.command.should == "find . -maxdepth 1 -name \"name*\" -a -type d | xargs -I xxx mv xxx name" }
  end

  describe 'link' do
    subject { link 'target', 'link' }
    it {subject.command.should == 'ln -sf target link'}
  end

  describe 'replace' do
    subject { replace('something', :with => 'some/path', :in => 'file') }
    it { subject.command.should == "sed -i \"s/something/some\\/path/\" file" }
    it { lambda{replace('something')}.should raise_error ArgumentError }
  end

  describe 'template' do
    it 'loads ERB template, applies settings and writes to remote machine' do
      File.should_receive(:open).with('erb_path').and_return('<%= method_on_binding %>')
      should_receive(:write).with('result', hash_including(:to => 'file'))
      template('erb_path', :settings => AppBuilder.new(:method_on_binding => 'result'), :to => 'file')
    end
  end

  describe 'mkdir' do
    subject { mkdir('path') }
    it { subject.command.should == 'mkdir -p path' }
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
end


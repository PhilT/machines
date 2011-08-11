require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  describe 'add_init_d' do
    before { Time.stub(:now).and_return Time.new(2011, 4, 2, 16, 37) }
    subject { add_init_d 'script_name' }
    it { subject.first.local.should == 'init.d/script_name' }
    it { subject.first.remote.should == '/etc/init.d/script_name' }
    it { subject.last.command.should == '/usr/sbin/update-rc.d -f script_name defaults' }
  end

  describe 'restart' do
    subject { restart 'daemon' }
    it { subject.command.should == 'service daemon restart' }
  end

  describe 'start' do
    subject { start 'daemon' }
    it { subject.command.should == 'service daemon start' }
  end
end


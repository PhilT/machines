require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  describe 'add_init_d' do
    subject { add_init_d 'name' }
    it { subject.first.local.should == 'name/initd' }
    it { subject.first.remote.should == '/etc/init.d/name' }
    it { subject.last.command.should == '/usr/sbin/update-rc.d -f name defaults' }
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


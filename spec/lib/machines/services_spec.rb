require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  describe 'add_upstart' do
    it 'writes a configuration' do
      should_receive(:write).with(%(description "description"\nrespawn\nexec command\n), :to => '/etc/init/name.conf', :name => 'name upstart')
      add_upstart 'name', :description => 'description', :respawn => true, :exec => 'command'
    end

    it 'adds a custom script to the configuration' do
      should_receive(:write).with(%(description "description"\ncustom script\n), :to => '/etc/init/name.conf', :name => 'name upstart')
      add_upstart 'name', :description => 'description', :custom => 'custom script'
    end
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


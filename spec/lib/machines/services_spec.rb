require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  before do
    alias :run :run_command # alias Machines::Core.run back so it can be called by sudo and the tests etc
  end

  describe 'add_upstart' do
    it 'writes a configuration' do
      expects(:write).with(%(description "description"\nrespawn\nexec command\n), :to => '/etc/init/name.conf', :name => 'name upstart')
      add_upstart 'name', :description => 'description', :respawn => true, :exec => 'command'
    end

    it 'adds a custom script to the configuration' do
      expects(:write).with(%(description "description"\ncustom script\n), :to => '/etc/init/name.conf', :name => 'name upstart')
      add_upstart 'name', :description => 'description', :custom => 'custom script'
    end
  end

  describe 'restart' do
    subject { restart 'daemon' }
    it { subject.command.must_equal 'service daemon restart' }
  end

  describe 'start' do
    subject { start 'daemon' }
    it { subject.command.must_equal 'service daemon start' }
  end
end


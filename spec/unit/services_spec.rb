require 'spec_helper'

describe 'Services' do
  include Machines::FileOperations
  include Machines::Services
  include FakeAddHelper

  describe 'add_init_d' do
    it 'should add a command to register a init.d startup script' do
      add_init_d 'script_name'
      @added.should == [['init.d/script_name', '/etc/init.d/script_name'], '/usr/sbin/update-rc.d -f script_name defaults']
    end
  end

  describe 'restart' do
    it 'should add a command to restart a daemon' do
      restart 'daemon'
      @added.should == ['service daemon restart']
    end
  end
end


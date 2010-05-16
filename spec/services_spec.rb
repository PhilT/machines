require 'spec/spec_helper'

describe 'Installation' do
  def add to_add
    @added << to_add
  end

  before(:each) do
    @added = []
  end

  describe 'add_init_d' do
    it 'should add a command to register a init.d startup script' do
      add_init_d 'script_name'
      @added.should == [['init.d/script_name', '/etc/init.d/script_name'], '/usr/sbin/update-rc.d -f script_name defaults']
    end
  end

  describe 'restart' do
    it 'should add a command to restart a daemon' do
      restart 'daemon'
      @added.should == ['/etc/init.d/daemon restart']
    end
  end
end


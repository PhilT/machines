require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  describe 'add_init_d' do
    it 'should add a command to register a init.d startup script' do
      add_init_d 'script_name'
      AppConf.commands.should == [
        Upload.new('', 'init.d/script_name', '/etc/init.d/script_name', 'test -s /etc/init.d/script_name && echo CHECK PASSED || echo CHECK FAILED'),
        Command.new('', 'export TERM=linux && /usr/sbin/update-rc.d -f script_name defaults', 'test -L /etc/rc0.d/K20script_name && echo CHECK PASSED || echo CHECK FAILED')]
    end
  end

  describe 'restart' do
    it 'should add a command to restart a daemon' do
      restart 'daemon'
      AppConf.commands.should == [Command.new('', 'export TERM=linux && service daemon restart', 'ps aux | grep daemon && echo CHECK PASSED || echo CHECK FAILED')]
    end
  end
end


require 'spec_helper'

describe 'Configuration' do
  include Machines::Core

  describe 'run' do
    before(:each) do
      AppConf.commands = []
    end

    it 'adds a command to the commands array and include the caller method name' do
      stub!(:caller).and_return ["(eval):13\nrest of trace"]
      run 'command', nil
      AppConf.commands.should == [Command.new('13', 'export TERM=linux && command', nil)]
    end

    it 'does not fail when no trace' do
      stub!(:caller).and_return []
      run 'command', nil
      AppConf.commands.should == [Command.new('', 'export TERM=linux && command', nil)]
    end

    it 'raises errors when command is missing' do
      stub!(:display)
      lambda{run [nil, nil]}.should raise_error(ArgumentError)
    end
  end

  describe 'sudo' do
    it 'wraps a command in a sudo with password call' do
      AppConf.user.pass = 'password'
      sudo 'command', nil
      AppConf.commands.should == [Command.new('', "echo password | sudo -S sh -c 'export TERM=linux && command'", nil)]
    end
  end
end


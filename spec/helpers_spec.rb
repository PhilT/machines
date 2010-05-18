require 'spec/spec_helper'

describe 'Helpers' do
  before(:each) do
    @commands = []
    @log = []
  end

  describe 'display' do
    before(:each) do
      @passwords = {:some_app => 'password'}
    end

    it 'should remove newlines' do
      display("multi\nline\ncommand").should == 'multi\line\command'
    end

    it 'should remove passwords' do
      display("multi\nline\ncommand with password").should == 'multi\line\command with ***'
    end

    it 'should flatten arrays' do
      display(['multi', 'command', 'array']).should == 'multi command array'
    end

    it 'should ignore empty password list' do
      @passwords = {}
      display('something nice').should == 'something nice'
    end
  end

  describe 'required_options' do
    it do
      lambda{required_options({:required => :option}, [:required])}.should_not raise_error(ArgumentError)
    end

    it do
      lambda{required_options({}, [:required])}.should raise_error(ArgumentError)
    end
  end

  describe 'add' do
    it 'should add a command to the commands array and include the caller method name' do
      add_command.should == [['add_command', 'command', nil]]
    end

    def add_command
      real_add 'command', nil
      @commands
    end
  end
end

describe 'log' do
  it 'should output messages to the console' do
    should_receive(:puts).with 'message'
    log 'message'
  end
end


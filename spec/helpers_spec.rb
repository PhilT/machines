require 'spec_helper'

describe 'Helpers' do
  include Machines::Helpers
  alias :real_add :add
  include FakeAddHelper

  before(:each) do
    @commands = []
  end

  describe 'display' do
    before(:each) do
      @passwords = {:some_app => 'password'}
    end

    it 'should remove passwords' do
      display("multi\nline\ncommand with password").should == "multi\nline\ncommand with ***"
    end

    it 'should flatten arrays' do
      display(['upload', 'path']).should == 'upload to path'
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

  describe 'log_result_to_file' do
    it 'should only output passed when check passed' do
      mock_file = mock File
      File.stub!(:open).and_yield mock_file
      mock_file.should_receive(:puts).with('CHECK PASSED')
      mock_file.stub!(:puts)
      log_result_to_file 'check', "something\nCHECK PASSED"
    end

    it 'should output whole check output when failed' do
      mock_file = mock File
      File.stub!(:open).and_yield mock_file
      mock_file.should_receive(:puts).with("something\nCHECK FAILED")
      mock_file.stub!(:puts)
      log_result_to_file 'check', "something\nCHECK FAILED"
    end

    it "should warn when nil check" do
      mock_file = mock(File)
      File.stub!(:open).and_yield mock_file
      mock_file.should_receive(:puts).with('NOT CHECKED')
      mock_file.should_receive(:puts).with("\n\n")
      log_result_to_file nil, nil
    end
  end

  describe 'add' do
    it 'should add a command to the commands array and include the caller method name' do
      stub!(:caller).and_return ["(eval):13\nrest of trace"]
      real_add 'command', nil
      @commands.should == [['13', 'command', nil]]
    end

    it 'should not fail when no trace' do
      stub!(:caller).and_return []
      real_add 'command', nil
      @commands.should == [['', 'command', nil]]
    end

    it 'should raise errors when command is missing' do
      stub!(:display)
      lambda{add [nil, nil]}.should raise_error(ArgumentError)
    end

  end
end


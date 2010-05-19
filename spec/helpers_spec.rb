require 'spec/spec_helper'

describe 'Helpers' do
  before(:each) do
    @commands = []
  end

  class String
    def green; self; end
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
      mock_file = mock(File)
      File.stub!(:open).and_yield mock_file
      mock_file.should_receive(:puts).with('CHECK PASSED')
      mock_file.stub!(:puts)
      log_result_to_file 'check', "something\nCHECK PASSED"
    end

    it 'should output whole check output when failed' do

    end

    it "should not test when nil check" do

    end
  end

  describe 'add' do
    it 'should add a command to the commands array and include the caller method name' do
      stub!(:caller).and_return ['Machinesfile:13']
      real_add 'command', nil
      @commands.should == [['13', 'command', nil]]
    end
  end
end


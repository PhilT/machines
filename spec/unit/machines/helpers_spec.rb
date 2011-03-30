require 'spec_helper'

describe 'Helpers' do
  include Machines::Core
  include Machines::Helpers

  before(:each) do
    AppConf.user.name = 'www'
    AppConf.from_hash(:log => {:output => mock(Logger, :info => nil, :error => nil), :progress => mock(Logger, :info => nil, :error => nil)})
  end

  describe 'display' do
    before(:each) do
      AppConf.passwords = ['password']
    end

    it 'should remove passwords' do
      display("multi\nline\ncommand with password").should == "multi\nline\ncommand with *****"
    end

    it 'should flatten arrays' do
      display(['upload', 'path']).should == 'upload to path'
    end

    it 'should ignore empty password list' do
      AppConf.passwords = []
      display('something nice').should == 'something nice'
    end

    it 'should not modify original' do
      command = "multi\nline\ncommand with password"
      display(command).should == "multi\nline\ncommand with *****"
      command.should == "multi\nline\ncommand with password"
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

  describe 'log_progress' do
    before(:each) do
      @log_message = 'log message'
      AppConf.commands = [1,2,3,4,5]
    end

    it 'logs progress of successful command' do
      AppConf.log.progress.should_receive(:info).with(@log_message)
      $terminal.should_receive(:color).with('[001 / 005] this is a successful log message', :green).and_return @log_message
      log_progress 1, "this is a successful log message", true
    end

    it 'logs progress of failed command' do
      AppConf.log.progress.should_receive(:error).with(@log_message)
      $terminal.should_receive(:color).with('[001 / 005] this is a failure log message', :red).and_return @log_message
      log_progress 1, "this is a failure log message", false
    end
  end

  describe 'log_output' do
    before(:each) do
      @log_message = 'log message'
      AppConf.log.output.should_receive(:info).with(@log_message)
    end

    it 'defaults to white' do
      $terminal.should_receive(:color).with('log message in white', :white).and_return @log_message
      log_output 'log message in white'
    end

    it 'logs with correct color' do
      $terminal.should_receive(:color).with('log message in color', :red).and_return @log_message
      log_output 'log message in color', :red
    end
  end

  describe 'check_result' do
    it 'returns CHECK PASSED when result contains CHECK PASSED' do
      check_result('blaCHECK PASSEDsomething').should == 'CHECK PASSED'
    end

    it 'returns CHECK FAILED when result contains CHECK FAILED' do
      check_result('blaCHECK FAILEDsomething').should == 'CHECK FAILED'
    end

    it 'returns NOT CHECKED when result contains neither CHECK PASSED nor CHECK FAILED' do
      check_result('').should == 'NOT CHECKED'
    end
  end

  describe 'log_result' do
    before(:each) do
      @log_message = 'log message'
      AppConf.log.output.should_receive(:info).with(@log_message)
    end

    it 'logs NOT CHECKED in yellow' do
      $terminal.should_receive(:color).with('NOT CHECKED', :yellow).and_return @log_message
      log_result 'NOT CHECKED'
    end

    it 'logs CHECK FAILED in red' do
      $terminal.should_receive(:color).with('CHECK FAILED', :red).and_return @log_message
      log_result 'CHECK FAILED'
    end

    it 'logs CHECK PASSED in green' do
      $terminal.should_receive(:color).with('CHECK PASSED', :green).and_return @log_message
      log_result 'CHECK PASSED'
    end
  end
end


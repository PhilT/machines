require 'spec_helper'

describe 'Helpers' do
  include Machines::Core
  include Machines::Logger

  before(:each) do
    AppConf.user.name = 'www'
  end

  describe 'put' do
    it 'sends a formatted message to the screen' do
      should_receive(:say).with 'formatted message'
      should_receive(:format_message).with('message', {}).and_return 'formatted message'
      put 'message', {}
    end
  end

  describe 'log' do
    it 'sends a formatted message to the log' do
      AppConf.log = mock File
      AppConf.log.should_receive(:puts).with 'formatted message'
      should_receive(:format_message).with('message', {}).and_return 'formatted message'
      log 'message', {}
    end
  end

  describe 'format_message' do
    before { AppConf.commands = [1,2,3] }

    it 'sends text to the screen' do
      put 'something'
      'something'.should be_displayed
    end

    it 'sends the command and line number' do
      put 'command', :progress => 0
      '(001/003) command'.should be_displayed
    end

    it 'displays message in green when success is true' do
      put 'command', :progress => 0, :success => true
      '(001/003) command'.should be_displayed in_green
    end

    it 'displays message in red when success is false' do
      put 'command', :progress => 0, :success => false
      '(001/003) command'.should be_displayed in_red
    end

    it 'displays message in specified color' do
      put 'command', :progress => 0, :color => :yellow
      '(001/003) command'.should be_displayed in_yellow
    end

    it 'does not show passwords' do
      AppConf.passwords = ['a_password', 'another password']
      put 'something with a_password and another password in'
      'something with ***** and ***** in'.should be_displayed
    end

    it 'does not break when no message' do
      put nil
      '(no message)'.should be_displayed
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

  describe 'color_for' do
    it do
      color_for('NOT CHECKED').should == :warning
    end

    it do
      color_for('CHECK FAILED').should == :failure
    end

    it do
      color_for('CHECK PASSED').should == :success
    end
  end
end


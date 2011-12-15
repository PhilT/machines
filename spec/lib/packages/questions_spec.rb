require 'spec_helper'

describe 'packages/questions' do
  before(:each) do
    load_package('questions')
    AppConf.machine = AppConf.new
  end

  it 'asks for a password' do
    should_receive(:enter_password).with('users', false)
    eval_package
  end

  it 'does not ask for a password when machine is EC2' do
    AppConf.machine.ec2 = {}
    should_not_receive(:enter_password)
    eval_package
  end

  it 'sets password when logging' do
    AppConf.log_only = true
    should_not_receive(:enter_password)
    eval_package
    AppConf.passwords.should == ['pa55word']
    AppConf.password.should == 'pa55word'
  end

end


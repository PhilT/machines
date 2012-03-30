require 'spec_helper'

describe 'packages/questions' do
  before(:each) do
    load_package('questions')
    $conf.machine = AppConf.new
  end

  it 'asks for a password' do
    expects(:enter_password).with('users', false)
    eval_package
  end

  it 'does not ask for a password when machine is EC2' do
    $conf.machine.ec2 = {}
    expects(:enter_password).never
    eval_package
  end

  it 'sets password when logging' do
    $conf.log_only = true
    expects(:enter_password).never
    eval_package
    $conf.passwords.must_equal ['pa55word']
    $conf.password.must_equal 'pa55word'
  end

end


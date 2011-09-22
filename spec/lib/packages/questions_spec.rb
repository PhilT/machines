require 'spec_helper'

describe 'packages/questions' do
  before(:each) do
    load_package('questions')
    AppConf.ec2 = AppConf.new
    AppConf.from_hash(:db => {})
    AppConf.from_hash(:appsroots => {:user_name => 'appsroot'})
    AppConf.stub(:load)
    stub!(:choose_machine).and_return 'machine'
    stub!(:load_app_settings)
    stub!(:start_ec2_instance?).and_return false
    stub!(:enter_target_address)
    stub!(:choose_user).and_return 'user_name'
    stub!(:enter_password)
  end

  it 'asks questions' do
    AppConf.machines = {'machine' => {:environment => :unknown, :apps => nil, :roles => nil}}
    should_receive(:choose_machine).and_return 'machine'
    should_receive(:start_ec2_instance?).and_return false
    should_receive(:enter_target_address).twice
    should_receive(:choose_user).and_return 'user_name'
    should_receive(:enter_password).with('users', false).once
    should_receive(:enter_password).with('database root').once
    eval_package
  end

  it 'does not ask questions when already set' do
    AppConf.machine = 'machine'
    AppConf.host = 'host'
    AppConf.user = 'user'
    AppConf.password = 'password'
    AppConf.machines = {'machine' => {:environment => :unknown, :apps => nil, :roles => nil}}
    should_not_receive(:choose_machine)
    should_not_receive(:start_ec2_instance?)
    should_not_receive(:enter_target_address)
    should_not_receive(:choose_user)
    should_not_receive(:enter_password)
    should_not_receive(:enter_password)
    eval_package
  end

  it 'loads app settings' do
    AppConf.machines = {'machine' => {:environment => :unknown, :apps => ['app1', 'app2'], :roles => nil}}
    should_receive(:load_app_settings).with(['app1', 'app2'])
    eval_package
  end

  describe 'staging' do
    it 'sets hostname to environment' do
      AppConf.machines = {'machine' => {:environment => :staging, :apps => nil, :roles => nil}}
      eval_package
      AppConf.hostname.should == :staging
    end
  end

  describe 'production' do
    it 'sets hostname to environment' do
      AppConf.machines = {'machine' => {:environment => :production, :apps => nil, :roles => nil}}
      eval_package
      AppConf.hostname.should == :production
    end
  end

  describe 'development' do
    it 'asks for hostname' do
    AppConf.machines = {'machine' => {:environment => :development, :apps => nil, :roles => nil}}
      should_receive(:enter_hostname)
      eval_package
    end
  end

  describe 'db role' do
    it 'does not ask for db host or password' do
      AppConf.machines = {'machine' => {:environment => :staging, :apps => nil, :roles => :db}}
      should_receive(:enter_target_address).once
      should_receive(:enter_password).once
      eval_package
    end
  end
end


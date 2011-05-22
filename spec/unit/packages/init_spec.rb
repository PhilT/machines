require 'spec_helper'

describe 'packages/init' do
  include Core
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/init.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.ec2 = AppConf.new
    AppConf.from_hash(:user_name => {:appsroot => 'appsroot'})
    AppConf.stub(:load)
    stub!(:choose_machine)
    stub!(:start_ec2_instance?).and_return false
    stub!(:enter_target_address)
    stub!(:choose_user).and_return 'user_name'
    stub!(:enter_password)
  end

  it 'loads AppConf with config.yml' do
    AppConf.should_receive(:load).with('/tmp/config/config.yml')
    eval @package
  end

  it 'asks questions' do
    should_receive(:choose_machine)
    should_receive(:start_ec2_instance?).and_return false
    should_receive(:enter_target_address).twice
    should_receive(:choose_user).and_return 'user_name'
    should_receive(:enter_password).twice
    eval @package
  end

  describe 'staging' do
    it 'sets hostname to environment' do
      AppConf.environments = AppConf.environment = :staging
      eval @package
      AppConf.hostname.should == :staging
    end
  end

  describe 'production' do
    it 'sets hostname to environment' do
      AppConf.environments = AppConf.environment = :production
      eval @package
      AppConf.hostname.should == :production
    end
  end

  describe 'development' do
    it 'asks for hostname' do
      AppConf.environment = :development
      should_receive(:enter_hostname)
      eval @package
    end
  end

  describe 'db role' do
    it 'does not ask for db host or password' do
      AppConf.roles = :db
      should_receive(:enter_target_address).once
      should_receive(:enter_password).once
      eval @package
    end
  end
end


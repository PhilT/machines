require 'spec_helper'

describe 'packages/questions' do
  before(:each) do
    load_package('questions')
    AppConf.ec2 = AppConf.new
    AppConf.from_hash(:db => {})
    AppConf.from_hash(:appsroots => {'user_name' => 'appsroot'})
    AppConf.stub(:load)
    stub!(:choose_machine).and_return 'machine'
    stub!(:load_app_settings)
    stub!(:enter_password)
    stub!(:connect)
    stub!(:run_instance)
    AppConf.machines = {
      'machine' => {
        'user' => 'user_name',
        'environment' => 'n_a',
        'roles' => ['db'],
        'address' => 'ip'
      }
    }
  end

  it 'asks questions' do
    should_receive(:choose_machine).and_return 'machine'
    eval_package
  end

  it 'does not ask questions when already set' do
    AppConf.machine = 'machine'
    AppConf.password = 'password'
    should_not_receive(:choose_machine)
    eval_package
  end

  describe 'setting address' do
    it 'raises an exception when no address' do
      AppConf.machines['machine']['address'] = nil
      lambda { eval_package }.should raise_error ConfigError
    end

    context 'when EC2' do
      before(:each) do
        AppConf.machines['machine']['ec2'] = true
      end

      it 'does not throw or connect when address set' do
        should_not_receive(:connect)
        eval_package
      end

      it 'starts a new instance when no address' do
        AppConf.machines['machine']['address'] = nil
        should_receive(:connect).and_return true
        should_receive(:run_instance)
        eval_package
      end
    end
  end

  it 'sets user' do
    eval_package
    AppConf.user.should == 'user_name'
  end

  it 'loads app settings' do
    AppConf.machines['machine']['apps'] = ['app1', 'app2']
    should_receive(:load_app_settings).with(['app1', 'app2'])
    eval_package
  end

  it 'sets hostname' do
    AppConf.machines['machine']['hostname'] = 'hostname'
    eval_package
    AppConf.hostname.should == 'hostname'
  end

  context 'when machine is a db server' do
    before(:each) do
      AppConf.machines['machine']['db'] = 'master'
      AppConf.machines['master'] = {'roles' => ['db'], 'replication_pass' => 'replpa55'}
    end

    it 'address set to localhost as used for app servers connecting locally' do
      eval_package
      AppConf.db.address.should == 'localhost'
    end

    it 'replication password set when machine points to another db' do
      eval_package
      AppConf.db.replication_pass.should == 'replpa55'
    end

    it 'no replication when no db specified' do
      AppConf.machines['machine']['db'] = nil
      eval_package
      AppConf.db.replication_pass.should be_nil
    end
  end
end


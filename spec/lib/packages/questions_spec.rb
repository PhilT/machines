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
    stub!(:enter_password)
    stub!(:connect)
    stub!(:run_instance)
  end

  it 'asks questions' do
    AppConf.machines = {'machine' => {'environment' => :n_a, 'apps' => nil, 'roles' => ['db'], 'address' => 'ip'}}
    should_receive(:choose_machine).and_return 'machine'
    eval_package
  end

  it 'does not ask questions when already set' do
    AppConf.machine = 'machine'
    AppConf.password = 'password'
    AppConf.machines = {'machine' => {'roles' => ['db'], 'address' => 'ip'}}
    should_not_receive(:choose_machine)
    eval_package
  end

  describe 'setting host' do
    it 'does not throw or connect to EC2 when set' do
      AppConf.machines = {'machine' => {'ec2' => true, 'address' => 'address', 'roles' => ['db']}}
      should_not_receive(:connect)
      eval_package
    end

    context 'when nil' do
      it 'starts a new instance when using EC2' do
        AppConf.machines = {'machine' => {'ec2' => true, 'roles' => ['db']}}
        should_receive(:connect).and_return true
        should_receive(:run_instance)
        eval_package
      end

      it 'raises an exception when not using EC2' do
        AppConf.machines = {'machine' => {'roles' => ['db']}}
        lambda { eval_package }.should raise_error NoHostAddressError
      end
    end
  end

  it 'loads app settings' do
    AppConf.machines = {'machine' => {'apps' => ['app1', 'app2'], 'roles' => ['db'], 'address' => 'ip'}}
    should_receive(:load_app_settings).with(['app1', 'app2'])
    eval_package
  end

  it 'sets hostname' do
    AppConf.machines = {'machine' => {'roles' => ['db'], 'address' => 'ip', 'hostname' => 'hostname'}}
    eval_package
    AppConf.hostname.should == 'hostname'
  end

  context 'when machine is a db server' do
    before(:each) do
      AppConf.machines = {'machine' => {'roles' => ['db'], 'address' => 'ip', 'db' => 'master'},
        'master' => {'roles' => ['db'], 'replication_pass' => 'replpa55'}}
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

  it 'sets db address for db roles' do
    AppConf.machines = {'machine' => {'roles' => ['db'], 'address' => 'ip'}}

  end

  it 'sets db address for non db roles' do
    AppConf.machines = {'machine' => {'roles' => ['db'], 'address' => 'ip'}}
  end

end


require 'spec_helper'

describe 'packages/load_machines' do
  let(:settings) do
    {'machines' => {'a_machine' => {'hostname' => 'something', 'user' => 'phil', 'address' => '1.2.3.4'}}}
  end

  def save_settings
    File.open('machines.yml', 'w') {|f| f.puts settings.to_yaml }
  end

  before(:each) do
    load_package('load_machines')
    AppConf.machine_name = 'a_machine'
    AppConf.from_hash('appsroots' => {'phil' => '/home/phil'})
    stub!(:load_app_settings)
    stub!(:connect)
    stub!(:run_instance)
  end

  describe 'loading machines.yml' do
    before(:each) do
      save_settings
    end
  
    it 'loads the machines.yml file' do
      eval_package
      AppConf.machines.a_machine.hostname.should == 'something'
    end

    it 'sets AppConf.machine using AppConf.machine_name' do
      eval_package
      AppConf.machine.hostname.should == 'something'
    end
  end

  describe 'setting address' do
    it 'raises an exception when no address' do
      settings['machines']['a_machine']['address'] = nil
      save_settings
      lambda { eval_package }.should raise_error ConfigError
    end

    context 'when EC2' do
      before(:each) do
        settings['machines']['a_machine']['ec2'] = {}
      end

      it 'does not throw or connect when address set' do
        save_settings
        should_not_receive(:connect)
        eval_package
      end

      it 'starts a new instance when no address' do
        settings['machines']['a_machine']['address'] = nil
        save_settings
        should_receive(:connect).and_return true
        should_receive(:run_instance)
        eval_package
      end
    end
  end

  it 'sets root_pass when not set' do
    stub!(:generate_password).and_return '1234'
    save_settings
    eval_package
    AppConf.machines.a_machine.root_pass.should == '1234'
  end

  it 'does not overwrite root_pass' do
    should_not_receive(:generate_password)
    settings['machines']['a_machine']['root_pass'] = 'something'
    save_settings
    eval_package
  end

  it 'sets user' do
    save_settings
    eval_package
    AppConf.machine.user.should == 'phil'
  end

  it 'loads app settings' do
    settings['machines']['a_machine']['apps'] = ['app1', 'app2']
    save_settings
    should_receive(:load_app_settings).with(['app1', 'app2'])
    eval_package
  end
end


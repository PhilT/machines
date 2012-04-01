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
    $conf.machine_name = 'a_machine'
    $conf.from_hash('appsroots' => {'phil' => '/home/phil'})
    stubs(:load_app_settings)
    stubs(:connect)
    stubs(:run_instance)
  end

  describe 'loading machines.yml' do
    before(:each) do
      save_settings
    end

    it 'loads the machines.yml file' do
      eval_package
      $conf.machines.a_machine.hostname.must_equal 'something'
    end

    it 'sets $conf.machine using $conf.machine_name' do
      eval_package
      $conf.machine.hostname.must_equal 'something'
    end
  end

  describe 'setting db_server' do
    it 'sets the db_server using the selected machines db_server' do
      settings['machines']['a_machine']['db_server'] = 'other_machine'
      settings['machines']['other_machine'] = {'hostname' => 'name', 'user' => 'fred', 'address' => '1.1.1.1'}
      save_settings
      eval_package
      $conf.db_server.user.must_equal 'fred'
      $conf.db_server.address.must_equal '1.1.1.1'
    end
  end

  describe 'setting address' do
    it 'raises an exception when no address' do
      settings['machines']['a_machine']['address'] = nil
      save_settings
      lambda { eval_package }.must_raise ConfigError
    end

    describe 'when EC2' do
      before(:each) do
        settings['machines']['a_machine']['ec2'] = {}
      end

      it 'does not throw or connect when address set' do
        save_settings
        expects(:connect).never
        eval_package
      end

      it 'starts a new instance when no address' do
        settings['machines']['a_machine']['address'] = nil
        save_settings
        expects(:connect).returns true
        expects(:run_instance)
        eval_package
      end
    end
  end

  it 'sets root_pass when not set' do
    stubs(:generate_password).returns '1234'
    save_settings
    eval_package
    $conf.machines.a_machine.root_pass.must_equal '1234'
  end

  it 'sets $conf.machines_changed when passwords are generated' do
    stubs(:generate_password).returns '1234'
    save_settings
    eval_package
    $conf.machines_changed.wont_equal nil
  end

  it '$conf.machines_changed not set when no passwords are generated' do
    settings['machines']['a_machine']['root_pass'] = '1234'
    save_settings
    eval_package
    $conf.machines_changed.must_equal nil
  end

  it 'does not overwrite root_pass' do
    expects(:generate_password).never
    settings['machines']['a_machine']['root_pass'] = 'something'
    save_settings
    eval_package
  end

  it 'sets user' do
    save_settings
    eval_package
    $conf.machine.user.must_equal 'phil'
  end

  it 'loads app settings' do
    settings['machines']['a_machine']['apps'] = ['app1', 'app2']
    save_settings
    expects(:load_app_settings).with(['app1', 'app2'])
    eval_package
  end
end


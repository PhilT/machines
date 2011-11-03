require 'spec_helper'

describe 'AppSettings' do
  include Machines::AppSettings
  include Machines::Configuration

  before(:each) do
    AppConf.webapps = {}
    AppConf.environment = :test
    AppConf.appsroot = '/home/user'
    @settings = {'app' => {
        'path' => 'path',
        'test' => {'setting' => 'setting'}
      }, 'another' => {'path' => 'other/path'}}
    File.stub(:open)
  end

  describe 'load_app_settings' do
    it 'loads settings from apps.yaml' do
      File.should_receive(:open).with('config/webapps.yml').and_return 'file'
      YAML.should_receive(:load).with('file').and_return({})
      load_app_settings ['app']
    end

    it 'loads the app settings for selected apps' do
      YAML.stub(:load).and_return(@settings)
      load_app_settings ['app']
      AppConf.webapps.should == {'app' => AppBuilder.new(:name => 'app', :path => 'path', :full_path => '/home/user/path', :setting => 'setting', :db_password => 'app')}
    end

    it 'handles ssl settings' do
      @settings['app']['test']['ssl'] = 'signed'
      YAML.stub(:load).and_return(@settings)
      load_app_settings ['app']
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :path => 'path',
          :full_path => '/home/user/path',
          :setting => 'setting',
          :ssl_key => 'signed.key',
          :ssl_crt => 'signed.crt',
          :ssl => 'signed',
          :db_password => 'app'
        )
      }
    end

    it 'raises when settings not included for specified environment' do
      YAML.stub(:load).and_return({'app' => {}})
      lambda{ load_app_settings(['app']) }.should raise_error(ArgumentError, 'No setttings for specified environment')
    end
  end
end


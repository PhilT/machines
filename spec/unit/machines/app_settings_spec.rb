require 'spec_helper'

describe 'AppSettings' do
  include Machines::AppSettings
  include Machines::Configuration

  before(:each) do
    AppConf.apps = {}
    AppConf.environment = :test
    AppConf.appsroot = '/home/user'
    @config = {

    }
    File.stub(:open)
  end

  describe 'load_app_settings' do
    it 'loads settings from apps.yaml' do
      File.should_receive(:open).with('/tmp/config/apps.yml').and_return 'file'
      YAML.should_receive(:load).with('file').and_return({})
      load_app_settings ['app']
    end

    it 'loads the app settings for selected apps' do
      YAML.stub(:load).and_return({'app' => {
        'path' => 'path',
        'test' => {
        }
      }, 'another' => {'path' => 'other/path'}})
      load_app_settings ['app']
      AppConf.apps.should == {'app' => AppBuilder.new(:name => 'app', :path => '/home/user/path')}
    end

    it 'raises when settings not included for specified environment' do
      YAML.stub(:load).and_return({'app' => {}})
      lambda{ load_app_settings(['app']) }.should raise_error(ArgumentError, 'No setttings for specified environment')
    end
  end
end


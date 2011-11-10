require 'spec_helper'

describe 'AppSettings' do
  before(:each) do
    AppConf.webapps = {}
    AppConf.environment = :test
    AppConf.appsroot = '/home/user'
    @settings = <<-EOF
---
app:
  path: path
  full_path: /home/user/path
  test:
    setting: setting
    ssl: signed
    EOF
    File.open('webapps.yml', 'w') {|f| f.puts @settings.gsub("    ssl: signed\n", '') }
  end

  describe 'load_app_settings' do
    it 'loads the app settings for selected apps' do
      load_app_settings ['app']
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :path => 'path',
          :full_path => '/home/user/path',
          :root => '/home/user/path/current/public',
          :setting => 'setting',
          :db_password => 'app'
        )
      }
    end

    it 'handles ssl settings' do
      File.open('webapps.yml', 'w') {|f| f.puts @settings }
      load_app_settings ['app']
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :path => 'path',
          :full_path => '/home/user/path',
          :root => '/home/user/path/current/public',
          :setting => 'setting',
          :ssl_key => 'signed.key',
          :ssl_crt => 'signed.crt',
          :ssl => 'signed',
          :db_password => 'app'
        )
      }
    end

    it 'raises when settings not included for specified environment' do
      File.open('webapps.yml', 'w') {|f| f.puts "---\napp:\n  path: path\n" }
      lambda{ load_app_settings(['app']) }.should raise_error(ArgumentError, 'app has no settings for test environment')
    end

    it 'loads settings for all apps when none specified' do
      settings = <<-EOF
---
app:
  path: path
  test:
    setting: setting
other:
  path: other_path
  test:
    setting: other_setting
      EOF
      File.open('webapps.yml', 'w') {|f| f.puts settings }
      load_app_settings nil
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :path => 'path',
          :full_path => '/home/user/path',
          :root => '/home/user/path/current/public',
          :setting => 'setting',
          :db_password => 'app'),
        'other' => AppBuilder.new(
          :name => 'other',
          :path => 'other_path',
          :root => '/home/user/other_path/current/public',
          :full_path => '/home/user/other_path',
          :setting => 'other_setting',
          :db_password => 'other')
      }
    end
  end
end


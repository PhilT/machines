require 'spec_helper'

describe 'AppSettings' do
  describe 'load_and_generate_passwords_for_webapps' do
    it 'generates passwords and saves to webapps.yml' do
      File.open('webapps.yml', 'w') {|f| f.puts "###\n\n---\nwebapps:\n  my_app:\n    development:\n      password: \n" }
      stub!(:generate_password).and_return 'random'
      load_and_generate_passwords_for_webapps
      File.read('webapps.yml').should == "###\n\n---\nwebapps:\n  my_app:\n    development:\n      password: random\n"
    end
  end

  describe 'load_app_settings' do
    before(:each) do
      AppConf.environment = :test
      AppConf.appsroot = '/home/user'
      @settings = <<-EOF
---
webapps:
  app:
    scm: scm://project.git
    test:
      setting: setting
      password: secure
      ssl: signed
EOF
      File.open('webapps.yml', 'w') {|f| f.puts @settings.gsub("      ssl: signed\n", '') }
    end

    it 'loads the app settings for selected apps' do
      load_app_settings ['app']
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :scm => 'scm://project.git',
          :name => 'app',
          :path => '/home/user/project',
          :root => '/home/user/project/current/public',
          :setting => 'setting',
          :password => 'secure'
        )
      }
    end

    it 'handles ssl settings' do
      File.open('webapps.yml', 'w') {|f| f.puts @settings }
      load_app_settings ['app']
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :scm => 'scm://project.git',
          :path => '/home/user/project',
          :root => '/home/user/project/current/public',
          :setting => 'setting',
          :password => 'secure',
          :ssl_key => 'signed.key',
          :ssl_crt => 'signed.crt',
          :ssl => 'signed'
        )
      }
    end

    it 'raises when settings not included for specified environment' do
      File.open('webapps.yml', 'w') {|f| f.puts "---\nwebapps:\n  app:\n    path: path\n" }
      lambda{ load_app_settings(['app']) }.should raise_error(ArgumentError, 'app has no settings for test environment')
    end

    it 'loads settings for all apps when none specified' do
      settings = <<-EOF
---
webapps:
  app:
    scm: scm://project.git
    test:
      setting: setting
      password: secure
  other:
    scm: scm://other_project
    test:
      setting: other_setting
      password: secure
      EOF
      File.open('webapps.yml', 'w') {|f| f.puts settings }
      load_app_settings nil
      AppConf.webapps.should == {
        'app' => AppBuilder.new(
          :name => 'app',
          :path => '/home/user/project',
          :scm => 'scm://project.git',
          :root => '/home/user/project/current/public',
          :setting => 'setting',
          :password => 'secure'),
        'other' => AppBuilder.new(
          :name => 'other',
          :root => '/home/user/other_project/current/public',
          :scm => 'scm://other_project',
          :path => '/home/user/other_project',
          :setting => 'other_setting',
          :password => 'secure')
      }
    end
  end
end


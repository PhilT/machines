require 'spec_helper'

describe AppSettings do

  subject { AppSettings.new }

  describe 'load_and_generate_passwords_for_webapps' do
    it 'generates passwords and saves to webapps.yml' do
      File.open('webapps.yml', 'w') {|f| f.puts "###\n\n---\nwebapps:\n  my_app:\n    development:\n      password: \n" }
      WEBrick::Utils.stubs(:random_string).returns 'random'
      subject.load_and_generate_passwords_for_webapps
      File.read('webapps.yml').must_equal "###\n\n---\nwebapps:\n  my_app:\n    development:\n      password: random\n"
    end
  end

  describe 'load' do
    before do
      $conf.environment = :test
      $conf.appsroot = '/home/user'
      @settings = <<-EOF
---
webapps:
  app:
    scm: scm://project.git
    test:
      setting: setting
      password: secure
      cert: signed
EOF
      File.open('webapps.yml', 'w') {|f| f.puts @settings.gsub("      cert: signed\n", '') }
    end

    it 'loads the app settings for selected apps' do
      subject.load ['app']
      $conf.webapps.must_equal({
        'app' => AppSettings::AppBuilder.new(
          :scm => 'scm://project.git',
          :name => 'app',
          :path => '/home/user/app',
          :root => '/home/user/app/current/public',
          :setting => 'setting',
          :password => 'secure'
        )
      })
    end

    it 'handles ssl settings' do
      File.open('webapps.yml', 'w') {|f| f.puts @settings }
      subject.load ['app']
      $conf.webapps.must_equal({
        'app' => AppSettings::AppBuilder.new(
          :name => 'app',
          :scm => 'scm://project.git',
          :path => '/home/user/app',
          :root => '/home/user/app/current/public',
          :setting => 'setting',
          :password => 'secure',
          :ssl_key => 'signed.key',
          :ssl_crt => 'signed.crt',
          :cert => 'signed',
          :ssl => true
        )
      })
    end

    it 'does not fail when settings not included for specified environment' do
      File.open('webapps.yml', 'w') {|f| f.puts "---\nwebapps:\n  app:\n    path: path\n" }
      subject.load(['app'])
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
      subject.load nil
      $conf.webapps.must_equal({
        'app' => AppSettings::AppBuilder.new(
          :name => 'app',
          :path => '/home/user/app',
          :scm => 'scm://project.git',
          :root => '/home/user/app/current/public',
          :setting => 'setting',
          :password => 'secure'),
        'other' => AppSettings::AppBuilder.new(
          :name => 'other',
          :root => '/home/user/other/current/public',
          :scm => 'scm://other_project',
          :path => '/home/user/other',
          :setting => 'other_setting',
          :password => 'secure')
      })
    end
  end
end


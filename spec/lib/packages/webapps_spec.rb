require 'spec_helper'

describe 'packages/webapps' do
  before(:each) do
    load_package('webapps')

    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir'}, :ruby => {:version => 'ruby_version'})
    AppConf.apps = {'application' => AppBuilder.new('name' => 'application', 'path' => 'app_path', 'enable_ssl' => nil, 'db_password' => 'pa$$')}
    AppConf.from_hash(:awstats => {:path => 'stats_path'})
    AppConf.webserver = 'nginx'
    AppConf.from_hash(:nginx => {:path => 'nginx_path', :servers_dir => 'servers'})
    AppConf.from_hash(:db => {:address => 'db_master'})
    FileUtils.mkdir_p '/prj/nginx'
    File.open('/prj/nginx/app_server.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    AppConf.environment = :production
    eval_package
    AppConf.commands.map(&:info).map{|info| info.gsub(" \n", "\n")}.should == [
      "TASK   webapps - Sets up Web apps in config/apps.yml using app_server.conf.erb",
      "SUDO   mkdir -p nginx_path/servers",
      "RUN    mkdir -p app_path/releases",
      "RUN    mkdir -p app_path/shared/config",
      "RUN    mkdir -p app_path/shared/system",
      "UPLOAD buffer from /prj/nginx/app_server.conf.erb to /tmp/application.conf",
      "SUDO   cp /tmp/application.conf nginx_path/servers/application.conf",
      "RUN    rm -f /tmp/application.conf",
      "UPLOAD buffer from database.yml to app_path/shared/config/database.yml",
    ]
  end

  it "doesn't make app structure when target is a development machine" do
    AppConf.environment = :development
    eval_package
    AppConf.commands.map(&:info).map{|info| info.gsub(" \n", "\n")}.should == [
      "TASK   webapps - Sets up Web apps in config/apps.yml using app_server.conf.erb",
      "SUDO   mkdir -p nginx_path/servers",
      "UPLOAD buffer from /prj/nginx/app_server.conf.erb to /tmp/application.conf",
      "SUDO   cp /tmp/application.conf nginx_path/servers/application.conf",
      "RUN    rm -f /tmp/application.conf",
    ]
  end
end

